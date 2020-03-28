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

import '../logic/sensor/rpc/rpc.dart' as rpc;
import '../logic/sensor/daemon.dart' as daemon;
import '../logic/controller/refresh.dart' as refresh;
import '../config.dart' as config;
import '../logging.dart';

import 'prototype.dart';
import 'synced.dart';
import 'exiting.dart';


class SyncingState extends AppState {
  final Queue<String> stdout = Queue();

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
