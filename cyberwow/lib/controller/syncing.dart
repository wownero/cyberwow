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

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'helper.dart';
import '../config.dart';

Stream<String> runBinary (String name) async* {
  final newPath = await getBinaryPath(name);

  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final binDir = new Directory(appDocDir.path + "/" + config.appPath);

  await binDir.create();

  // print('binDir: ' + binDir.path);
  const List<String> debugArgs =
  [
  ];
  const List<String> releaseArgs =
  [
    "--restricted-rpc"
  ];

  const extraArgs = kReleaseMode ? releaseArgs : debugArgs;

  final args =
  [
    "--data-dir",
    binDir.path,
    "--non-interactive",
  ] + extraArgs + config.extraArgs;

  log.info('args: ' + args.toString());

  final outputProcess = await Process.start(newPath, args);
  await for (var line in outputProcess.stdout.transform(utf8.decoder)) {
    yield line;
  }

  // the app should never reach here
  log.severe('Daemon is gone!');
  exit(1);
}
