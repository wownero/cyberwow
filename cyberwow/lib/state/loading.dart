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

import '../controller/helper.dart';
import '../config.dart' as config;
import '../logging.dart';

import 'prototype.dart';
import 'syncing.dart';

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
