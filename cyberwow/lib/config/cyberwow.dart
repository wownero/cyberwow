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

  scaffoldBackgroundColor: Colors.black,

  fontFamily: 'RobotoMono',

  textTheme: TextTheme
  (
    display1: TextStyle
    (
      fontSize: 35,
      fontWeight: FontWeight.bold,
    ),
    subhead: TextStyle
    (
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    body2: TextStyle
    (
      fontSize: 11,
    ),
  ).apply
  (
    bodyColor: Colors.green,
    displayColor: Colors.green,
  ),

  // cursorColor: config.c.textColor,
  // inputDecorationTheme: InputDecorationTheme
  // (
  //   focusedBorder: UnderlineInputBorder
  //   (
  //     borderSide: BorderSide(color: config.c.textColor)
  //   )
  // )
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
);
