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

const crtGreen = Color.fromRGBO(0, 255, 102, 1);

final _theme = ThemeData
(
  brightness: Brightness.dark,

  primaryColor: crtGreen,
  hintColor: Colors.yellow,
  accentColor: crtGreen,
  cursorColor: crtGreen,

  scaffoldBackgroundColor: Colors.black,

  textTheme: TextTheme
  (
    display1: TextStyle
    (
      fontFamily: 'RobotoMono',
      fontSize: 35,
      fontWeight: FontWeight.bold,
    ),
    display2: TextStyle
    (
      fontFamily: 'RobotoMono',
      fontSize: 22,
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
    bodyColor: crtGreen,
    displayColor: crtGreen,
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
    '--no-igd',
    '--check-updates=disabled',
    '--disable-dns-checkpoints',
  ],
  '[1337@cyberwow]: ',
  6,
);
