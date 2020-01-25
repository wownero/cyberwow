/*

Copyright 2020 fuwa

This file is part of CyberWOW.

Wowllet is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Wowllet is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Wowllet.  If not, see <https://www.gnu.org/licenses/>.

*/

import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../logging.dart';

const _methodChannel = const MethodChannel('send-intent');

Future<String> getBinaryDir() async {
  final _dir = await _methodChannel.invokeMethod('getBinaryDir');

  final _binDir = Directory(_dir);
  final _bins = _binDir.listSync(recursive: true);

  return _dir;
}

Future<String> getBinaryPath(final String name) async {
  final _binaryDir = await getBinaryDir();
  return _binaryDir + '/' + name;
}
