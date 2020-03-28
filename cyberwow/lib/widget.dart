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

import 'state.dart';
import 'widget/blank.dart' as blank;
import 'widget/loading.dart' as loading;
import 'widget/syncing.dart' as syncing;
import 'widget/synced.dart' as synced;
import 'widget/resyncing.dart' as resyncing;
import 'widget/exiting.dart' as exiting;

Widget build(final BuildContext context, final AppState state) {
  switch (state.runtimeType) {
    case BlankState: return blank.build(context, state);
    case LoadingState: return loading.build(context, state);
    case SyncingState: return syncing.build(context, state);
    case SyncedState: return synced.build(context, state);
    case ReSyncingState: return resyncing.build(context, state);
    case ExitingState: return exiting.build(context, state);
    default: return Placeholder();
  }
}
