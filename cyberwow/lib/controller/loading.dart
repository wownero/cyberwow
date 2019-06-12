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

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'helper.dart';

Stream<String> deployBinary (AssetBundle bundle, String path, String name) async* {
  final binData = await bundle.load(path);
  final newPath = await getBinaryPath(name);

  yield 'output binary path: $newPath\n';

  final inputBytes = binData.buffer.asUint8List();
  final outputFile = await new File(newPath).writeAsBytes(inputBytes);

  final chmodResult = await Process.run('chmod', ['u+x', newPath]);
  yield chmodResult.stderr + '\n';

  final outputStat = await outputFile.stat();
  yield outputStat.toString() + '\n';
}
