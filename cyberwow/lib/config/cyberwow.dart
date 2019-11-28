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

import 'prototype.dart';

final _theme = ThemeData
(
  brightness: Brightness.dark,

  primaryColor: Colors.green,
  hintColor: Colors.yellow,
  primarySwatch: Colors.green,
  accentColor: Colors.green,
  cursorColor: Colors.green,

  scaffoldBackgroundColor: Colors.black,

  textTheme: TextTheme
  (
    display1: TextStyle
    (
      fontFamily: 'RobotoMono',
      fontSize: 35,
      fontWeight: FontWeight.bold,
    ),
    title: TextStyle
    (
      fontFamily: 'VT323',
      fontSize: 22,
    ),
    subhead: TextStyle
    (
      fontFamily: 'RobotoMono',
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    body1: TextStyle
    (
      fontFamily: 'VT323',
      fontSize: 17,
      height: 1,
    ),
    body2: TextStyle
    (
      fontFamily: 'RobotoMono',
      fontSize: 12.5,
    ),
  ).apply
  (
    bodyColor: Colors.green,
    displayColor: Colors.green,
  ),
);


final config = CryptoConfig
(
  'wownerod',
  'wownerod',
  'Follow the white rabbit.',
  70,
  _theme,
  34568,
  [
    '--prune-blockchain',
    '--max-concurrency=1',
    '--fast-block-sync=1',
    '--block-sync-size=5',
  ],
  '[1337@cyberwow]: ',
);
