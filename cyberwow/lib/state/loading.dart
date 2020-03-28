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

import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart' as config;
import '../logging.dart';
import '../helper.dart';

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

  Future<SyncingState> next() async {
    Future<void> showBanner() async {
      final Iterable<String> chars = banner.runes.map((x) => String.fromCharCode(x));

      for (final String char in chars) {
        append(char);
        await Future.delayed(Duration(milliseconds: config.c.splashDelay));
      }

      await tick();
      await tick();
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final _bannerShown = await _prefs.getBool(config.bannerShownKey);

    if (_bannerShown == null) {
      await showBanner();
      await _prefs.setBool(config.bannerShownKey, true);
    }

    SyncingState _next = SyncingState(appHook);
    return moveState(_next);
  }
}
