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

import 'dart:collection';

import '../config.dart' as config;
import '../logging.dart';

import 'prototype.dart';

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

  Future<void> wait() async {
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
