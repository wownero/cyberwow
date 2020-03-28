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


import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../config.dart' as config;
import '../logic/sensor/daemon.dart' as daemon;
import '../logic/controller/refresh.dart' as refresh;
import '../logic/sensor/rpc/rpc.dart' as rpc;
import '../logic/sensor/rpc/rpc2.dart' as rpc;
import '../logic/view/rpc/rpc2.dart' as rpc2View;
import '../logic/view/rpc/rpc.dart' as rpcView;
import '../helper.dart';
import '../logging.dart';

import 'prototype.dart';
import 'resyncing.dart';
import 'exiting.dart';

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
    stdout.addLast(config.c.promptString + line);
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


