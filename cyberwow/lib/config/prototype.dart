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

class CryptoConfig {
  final String outputBin;
  final String appPath;
  final String splash;
  final int splashDelay;
  final ThemeData theme;
  final int port;
  final List<String> extraArgs;
  final String promptString;
  final int hashViewBlockLength;
  const CryptoConfig
  (
    this.outputBin,
    this.appPath,
    this.splash,
    this.splashDelay,
    this.theme,
    this.port,
    this.extraArgs,
    this.promptString,
    this.hashViewBlockLength,
  );
}
