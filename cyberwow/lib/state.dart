/*

Copyright 2019 fuwa

This file is part of CyberWOW.

CyberWOW is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CyberWOW is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CyberWOW.  If not, see <https://www.gnu.org/licenses/>.

*/

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'controller/helper.dart';
import 'controller/rpc/rpc.dart' as rpc;
import 'controller/rpc/rpc2.dart' as rpc;
import 'controller/daemon.dart' as daemon;
import 'controller/refresh.dart' as refresh;
import 'config.dart' as config;
import 'logging.dart';

abstract class AppState {
  T use<T>
  (
    T Function(BlankState) useBlankState,
    T Function(LoadingState) useLoadingState,
    T Function(SyncingState) useSyncingState,
    T Function(SyncedState) useSyncedState,
    T Function(ReSyncingState) useReSyncingState,
  )
  {
    if (this is BlankState) {
      return useBlankState(this);
    }
    if (this is LoadingState) {
      return useLoadingState(this);
    }
    if (this is SyncingState) {
      return useSyncingState(this);
    }
    if (this is SyncedState) {
      return useSyncedState(this);
    }
    if (this is ReSyncingState) {
      return useReSyncingState(this);
    }
    throw Exception('Invalid state');
  }
}

typedef SetStateFunc = void Function(AppState);
typedef GetNotificationFunc = AppLifecycleState Function();
typedef IsExitingFunc = bool Function();

class HookedState extends AppState {
  final SetStateFunc setState;
  final GetNotificationFunc getNotification;
  final GetExitingFunc isExiting;
  HookedState(this.setState, this.getNotification, this.isExiting);

  syncState() {
    setState(this);
  }

  HookedState moveState(HookedState _next) {
    setState(_next);
    return _next;
  }
}

class BlankState extends HookedState {
  BlankState(f, s) : super (f, s);

  Future<LoadingState> next(String status) async {
    LoadingState _next = LoadingState(setState, getNotification, status);
    return moveState(_next);
  }
}

class LoadingState extends HookedState {
  String banner;
  String status = '';

  LoadingState(f, s, this.banner) : super (f, s);

  void append(String msg) {
    this.status += msg;
    syncState();
  }


  Future<SyncingState> next(Stream<String> loadingProgress, String status) async {
    Future<void> showBanner() async {
      var chars = [];
      banner.runes.forEach((int rune) {
          final c = new String.fromCharCode(rune);
          chars.add(c);
      });

      for (String char in chars) {
        append(char);
        await Future.delayed(Duration(milliseconds: config.c.splashDelay), () => "1");
      }

      await Future.delayed(const Duration(seconds: 2), () => "1");
    }

    Future<void> load() async {
      log.fine("Loading next");
      await for (final line in loadingProgress) {
        // append(line);
        log.info(line);
      }
    }

    final outputBinExists = await binaryExists(config.c.outputBin);
    if (outputBinExists) {
      await load();
    }
    else {
      await Future.wait([load(), showBanner()]);
    }

    SyncingState _next = SyncingState(setState, getNotification);
    return moveState(_next);
  }
}

class SyncingState extends HookedState {
  Queue<String> stdout = Queue();
  bool synced = false;

  SyncingState(f, s) : super (f, s);

  void append(String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<SyncedState> next(StreamSink<String> processInput, Stream<String> processOutput) async {
    log.fine("Syncing next");

    Future<void> printStdout() async {
      await for (final line in processOutput) {
        if (synced) break;
        log.finest('syncing: print stdout loop');

        append(line);
        log.info(line);
      }
    }

    Future<void> checkSync() async {
      await for (final _null in refresh.pull(getNotification, 'syncingState')) {
        log.finer('SyncingState: checkSync loop');

        // here doc is wrong, targetHeight could match height when synced
        // potential bug, targetHeight could be smaller then height
        final _isConnected = await daemon.isConnected();
        final _isSynced = await daemon.isSynced();

        if (_isConnected && _isSynced) {
          synced = true;
          break;
        }
      }
    }

    printStdout();
    await checkSync();

    log.fine('syncing: loop exit');

    // processInput.add('exit');

    final _height = await rpc.height();
    SyncedState _next = SyncedState(setState, getNotification, stdout, processInput, processOutput);
    _next.height = _height;
    return moveState(_next);
  }
}

class SyncedState extends HookedState {
  Queue<String> stdout;
  int height;
  StreamSink<String> processInput;
  Stream<String> processOutput;
  bool synced = true;
  bool connected = true;
  Map<String, dynamic> getInfo = {};
  String syncInfo = 'syncInfo';
  List<dynamic> getConnections = [];
  List<dynamic> getTransactionPool = [];

  SyncedState(f, s, this.stdout, this.processInput, this.processOutput) : super (f, s);

  void appendInput(String line) {
    stdout.addLast('> ' + line + '\n');
    processInput.add(line);
  }

  Future<ReSyncingState> next() async {
    log.fine("Synced next");

    Future<void> logStdout() async {
      await for (final line in processOutput) {
        if (!synced) break;
        // print('synced: print stdout loop');
        stdout.addLast(line);
        log.info(line);
      }
    }

    logStdout();

    Future<void> checkSync() async  {
      await for (final _null in refresh.pull(getNotification, 'syncedState')) {
        if (await daemon.isNotSynced()) {
          synced = false;
          break;
        }
        // log.finer('SyncedState: checkSync loop');
        height = await rpc.height();
        connected = await daemon.isConnected();
        getInfo = await rpc.getInfoSimple();
        // syncInfo = await rpc.syncInfoString();
        getConnections = await rpc.getConnectionsSimple();
        // getTransactionPool = await rpc.getTransactionPoolString();

        getTransactionPool = await rpc.getTransactionPoolSimple();

        // appendInput('help');

        // log.fine('getTransactionPool: $getTransactionPool');
        syncState();
      }
    }

    await checkSync();

    log.fine('synced: loop exit');

    ReSyncingState _next = ReSyncingState(setState, getNotification, stdout, processInput, processOutput);
    return moveState(_next);
  }
}


class ReSyncingState extends HookedState {
  Queue<String> stdout;
  StreamSink<String> processInput;
  Stream<String> processOutput;
  bool synced = false;

  ReSyncingState(f, s, this.stdout, this.processInput, this.processOutput) : super (f, s);

  void append(String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<SyncedState> next() async {
    log.fine("ReSyncing next");

    Future<void> printStdout() async {
      await for (final line in processOutput) {
        if (synced) break;
        // print('re-syncing: print stdout loop');
        append(line);
        log.info(line);
      }
    }

    Future<void> checkSync() async {
      await for (final _null in refresh.pull(getNotification, 'ReSyncingState')) {

        if (await daemon.isSynced()) {
          synced = true;
          break;
        }
        // print('re-syncing: checkSync loop');
      }
    }

    printStdout();
    await checkSync();

    log.fine('resync: await exit');
    SyncedState _next = SyncedState(setState, getNotification, stdout, processInput, processOutput);
    _next.height = await rpc.height();
    return moveState(_next);
  }
}

class ExitingState extends HookedState {
  Queue<String> stdout;
  Stream<String> processOutput;

  ExitingState(f, s, this.stdout, this.processOutput) : super (f, s);

  void append(String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<SyncedState> wait() async {
    log.fine("Exiting wait");

    Future<void> printStdout() async {
      await for (final line in processOutput) {
        if (synced) break;
        log.finest('exiting: print stdout loop');

        append(line);
        log.info(line);
      }
    }

    await printStdout();
  }
}
