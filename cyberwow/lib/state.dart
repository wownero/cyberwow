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

typedef SetStateFunc = void Function(AppState);
typedef GetNotificationFunc = AppLifecycleState Function();
typedef IsExitingFunc = bool Function();

class AppHook {
  final SetStateFunc setState;
  final GetNotificationFunc getNotification;
  final IsExitingFunc isExiting;
  AppHook(this.setState, this.getNotification, this.isExiting);
}

class AppState {
  final AppHook appHook;
  AppState(this.appHook);

  syncState() {
    appHook.setState(this);
  }

  AppState moveState(AppState _next) {
    appHook.setState(_next);
    return _next;
  }
}

class BlankState extends AppState {
  BlankState(appHook) : super (appHook);

  Future<LoadingState> next(String status) async {
    LoadingState _next = LoadingState(appHook, status);
    return moveState(_next);
  }
}

class LoadingState extends AppState {
  final String banner;
  String status = '';

  LoadingState(appHook, this.banner) : super (appHook);

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

    SyncingState _next = SyncingState(appHook);
    return moveState(_next);
  }
}

class SyncingState extends AppState {
  final Queue<String> stdout = Queue.from(['']);

  bool synced = false;

  SyncingState(appHook) : super (appHook);

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<AppState> next
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
      await for (final _null in refresh.pull(appHook.getNotification, 'syncingState')) {
        log.finer('SyncingState: checkSync loop');

        if (appHook.isExiting()) {
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

    if (appHook.isExiting()) {
      ExitingState _next = ExitingState
      (
        appHook, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('syncing: loop exit');

    // processInput.add('exit');

    final _height = await rpc.height();
    SyncedState _next = SyncedState
    (
      appHook, stdout, processInput, processOutput, 1,
    );
    _next.height = _height;
    return moveState(_next);
  }
}

class SyncedState extends AppState {
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

  SyncedState(appHook, this.stdout, this.processInput, this.processOutput, this.pageIndex)
  : super (appHook) {
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

  Future<AppState> next() async {
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
      await for (final _null in refresh.pull(appHook.getNotification, 'syncedState')) {
        if (appHook.isExiting() || userExit) {
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
        getInfo = await rpc.getInfoSimple();
        final _getInfoView = cleanKey(rpcView.getInfoView(getInfo));
        getInfoCache = pretty(_getInfoView);

        getConnections = await rpc.getConnectionsSimple();
        final List<Map<String, dynamic>> _getConnectionsView =
        getConnections
        .map(rpcView.getConnectionView)
        .map((x) => rpcView.simpleHeight(height, x))
        .map(cleanKey)
        .toList();
        getConnectionsCache = pretty(_getConnectionsView);

        getTransactionPool = await rpc.getTransactionPoolSimple();
        final List<Map<String, dynamic>> _getTransactionPoolView =
        getTransactionPool.map(rpc2View.txView).map(cleanKey).toList();
        getTransactionPoolCache = pretty(_getTransactionPoolView);

        syncState();
      }
    }

    await checkSync();

    if (appHook.isExiting() || userExit) {
      ExitingState _next = ExitingState
      (
        appHook, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('synced: loop exit');

    ReSyncingState _next = ReSyncingState
    (
      appHook, stdout, processInput, processOutput, pageIndex
    );
    return moveState(_next);
  }
}


class ReSyncingState extends AppState {
  final Queue<String> stdout;
  final StreamSink<String> processInput;
  final Stream<String> processOutput;
  final int pageIndex;

  bool synced = false;

  ReSyncingState(appHook, this.stdout, this.processInput, this.processOutput, this.pageIndex)
    : super (appHook);

  void append(final String msg) {
    stdout.addLast(msg);
    while (stdout.length > config.stdoutLineBufferSize) {
      stdout.removeFirst();
    }
    syncState();
  }

  Future<AppState> next() async {
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
      await for (final _null in refresh.pull(appHook.getNotification, 'ReSyncingState')) {
        if (appHook.isExiting()) {
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

    if (appHook.isExiting()) {
      ExitingState _next = ExitingState
      (
        appHook, stdout, processOutput
      );
      return moveState(_next);
    }

    log.fine('resync: await exit');
    SyncedState _next = SyncedState
    (
      appHook, stdout, processInput, processOutput, pageIndex
    );
    _next.height = await rpc.height();
    return moveState(_next);
  }
}

class ExitingState extends AppState {
  final Queue<String> stdout;
  final Stream<String> processOutput;

  ExitingState(appHook, this.stdout, this.processOutput) : super (appHook);

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
