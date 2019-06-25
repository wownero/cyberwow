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

import 'dart:ui';
import 'dart:async';
import 'rpc.dart' as rpc;

typedef GetNotificationFunc = AppLifecycleState Function();

Stream<int> targetHeight(GetNotificationFunc getNotification) async* {
  while (true) {
    final _appState = getNotification();
    print('refresh targetHeight: app state: ${_appState}');

    if (_appState == AppLifecycleState.resumed) {
      final _targetHeight = await rpc.targetHeight();
      yield _targetHeight
    }

    await Future.delayed(const Duration(seconds: 2), () => "1");
  }
}
