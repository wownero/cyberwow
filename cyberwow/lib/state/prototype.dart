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
