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
import 'helper.dart';
import 'controller/rpc/rpcView.dart' as rpcView;
import 'controller/rpc/rpc2View.dart' as rpc2View;

abstract class AppState {
  T use<T>
  (
    T Function(BlankState) useBlankState,
    T Function(LoadingState) useLoadingState,
    T Function(SyncingState) useSyncingState,
    T Function(SyncedState) useSyncedState,
    T Function(ReSyncingState) useReSyncingState,
    T Function(ExitingState) useExitingState,
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
    if (this is ExitingState) {
      return useExitingState(this);
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
  final IsExitingFunc isExiting;
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
  BlankState(f1, f2, f3) : super (f1, f2, f3);

  Future<LoadingState> next(String status) async {
    LoadingState _next = LoadingState(setState, getNotification, isExiting, status);
    return moveState(_next);
  }
}

class LoadingState extends HookedState {
  final String banner;
  String status = '';

  LoadingState(f1, f2, f3, this.banner) : super (f1, f2, f3);

  void append(final String msg) {
    this.status += msg;
    syncState();
  }


  Future<SyncingState> next(Stream<String> loadingProgress, String status) async {
    Future<void> showBanner() async {
      var chars = [];
      banner.runes.forEach((int rune) {
          final c = String.fromCharCode(rune);
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

    SyncingState _next = SyncingState(setState, getNotification, isExiting);
    return moveState(_next);
  }
}

class SyncingState extends HookedState {
  final Queue<String> stdout = Queue.from(['']);

  bool synced = false;

  SyncingState(f1, f2, f3) : super (f1, f2, f3);

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<HookedState> next
  (
    StreamSink<String> processInput, Stream<String> processOutput
  ) async {
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

        if (isExiting()) {
          log.fine('Syncing state detected exiting');
          break;
        }

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

    if (isExiting()) {
      ExitingState _next = ExitingState
      (
        setState, getNotification, isExiting, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('syncing: loop exit');

    // processInput.add('exit');

    final _height = await rpc.height();
    SyncedState _next = SyncedState
    (
      setState, getNotification, isExiting, stdout, processInput, processOutput, 1,
    );
    _next.height = _height;
    return moveState(_next);
  }
}

class SyncedState extends HookedState {
  final Queue<String> stdout;
  final StreamSink<String> processInput;
  final Stream<String> processOutput;
  final TextEditingController textController = TextEditingController();

  int height;
  bool synced = true;
  bool userExit = false;
  bool connected = true;
  Map<String, dynamic> getInfo = {};
  List<Map<String, dynamic>> getConnections = [];
  List<Map<String, dynamic>> getTransactionPool = [];
  int pageIndex;
  String syncInfo = 'syncInfo';
  PageController pageController;

  String getInfoCache = '';
  String getConnectionsCache = '';
  String getTransactionPoolCache = '';

  SyncedState(f1, f2, f3, this.stdout, this.processInput, this.processOutput, this.pageIndex)
  : super (f1, f2, f3) {
    pageController = PageController( initialPage: pageIndex );
  }

  void appendInput(final String line) {
    stdout.addLast(config.c.promptString + line + '\n');
    syncState();
    processInput.add(line);

    if (line == 'exit') {
      userExit = true;
    }
  }

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  void onPageChanged(int value) {
    this.pageIndex = value;
  }

  Future<HookedState> next() async {
    log.fine("Synced next");

    Future<void> logStdout() async {
      await for (final line in processOutput) {
        if (!synced) break;

        // print('synced: print stdout loop');
        append(line);
        log.info(line);
      }
    }

    logStdout();

    Future<void> checkSync() async  {
      await for (final _null in refresh.pull(getNotification, 'syncedState')) {
        if (isExiting() || userExit) {
          log.fine('Synced state detected exiting');
          break;
        }

        if (await daemon.isNotSynced()) {
          synced = false;
          break;
        }
        // log.finer('SyncedState: checkSync loop');
        height = await rpc.height();
        connected = await daemon.isConnected();
        final _getInfo = await rpc.getInfoSimple();
        getInfo = cleanKey(rpcView.getInfoView(_getInfo));
        getInfoCache = pretty(getInfo);

        final List<Map<String, dynamic>> _getConnections = await rpc.getConnectionsSimple();
        getConnections = _getConnections
        .map(rpcView.getConnectionView)
        .map((x) => rpcView.simpleHeight(height, x))
        .map(cleanKey)
        .toList();
        getConnectionsCache = pretty(getConnections);

        final List<Map<String, dynamic>> _getTransactionPool = await rpc.getTransactionPoolSimple();
        getTransactionPool = _getTransactionPool.map(rpc2View.txView).map(cleanKey).toList();
        getTransactionPoolCache = pretty(getTransactionPool);

        syncState();
      }
    }

    await checkSync();

    if (isExiting() || userExit) {
      ExitingState _next = ExitingState
      (
        setState, getNotification, isExiting, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('synced: loop exit');

    ReSyncingState _next = ReSyncingState
    (
      setState, getNotification, isExiting, stdout, processInput, processOutput, pageIndex
    );
    return moveState(_next);
  }
}


class ReSyncingState extends HookedState {
  final Queue<String> stdout;
  final StreamSink<String> processInput;
  final Stream<String> processOutput;
  final int pageIndex;

  bool synced = false;

  ReSyncingState(f1, f2, f3, this.stdout, this.processInput, this.processOutput, this.pageIndex)
    : super (f1, f2, f3);

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<HookedState> next() async {
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
        if (isExiting()) {
          log.fine('ReSyncing state detected exiting');
          break;
        }

        if (await daemon.isSynced()) {
          synced = true;
          break;
        }
        // print('re-syncing: checkSync loop');
      }
    }

    printStdout();
    await checkSync();

    if (isExiting()) {
      ExitingState _next = ExitingState
      (
        setState, getNotification, isExiting, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('resync: await exit');
    SyncedState _next = SyncedState
    (
      setState, getNotification, isExiting, stdout, processInput, processOutput, pageIndex
    );
    _next.height = await rpc.height();
    return moveState(_next);
  }
}

class ExitingState extends HookedState {
  final Queue<String> stdout;
  final Stream<String> processOutput;

  ExitingState(f1, f2, f3, this.stdout, this.processOutput) : super (f1, f2, f3);

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<SyncedState> wait() async {
    log.finer("Exiting wait");

    Future<void> printStdout() async {
      await for (final line in processOutput) {
        log.finer('exiting: print stdout loop');

        append(line);
        log.info(line);
      }
    }

    await printStdout();

    log.finer('exiting state done');
  }
}
