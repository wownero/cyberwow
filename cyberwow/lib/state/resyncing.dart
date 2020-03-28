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

import '../logic/controller/refresh.dart' as refresh;
import '../logic/sensor/rpc/rpc.dart' as rpc;
import '../logic/sensor/daemon.dart' as daemon;
import '../config.dart' as config;
import '../logging.dart';

import 'prototype.dart';
import 'synced.dart';
import 'exiting.dart';


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
