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

import 'dart:convert';
import 'dart:math';

import 'config.dart' as config;

String pretty(dynamic x) {
  final JsonEncoder encoder = JsonEncoder.withIndent('');
  return encoder.convert(x)
         .replaceAll(RegExp(r'^{'), '\n')
         .replaceAll(RegExp(r'(["\[\],{}]|: )'), '')
         ;
}

String trimHash(String x) {
  final l = config.c.hashViewBlockLength;
  return x.substring(0, l) + '-' + x.substring(l, l * 2) + ' ...';
}

Map<String, dynamic> cleanKey(Map<String, dynamic> x) {
  final _cleaned = x.map
  (
    (k, v) => MapEntry
    (
      k
      .replaceAll('cumulative', 'Σ')
      .replaceAll('current_', '')
      .replaceAll('_', ' ')
      ,
      v
    )
  );


  final int _maxLength = _cleaned.keys.map((x) => x.length).reduce(max);
  final _padded = _cleaned.map
  (
    (k, v) => MapEntry(k.padRight(_maxLength + 2, ' '), v)
  );

  return _padded;
}

int asInt(dynamic x) => x?.toInt() ?? 0;

bool asBool(dynamic x) => x ?? false;

List<dynamic> asList(dynamic x) => x ?? [];
List<Map<String, dynamic>> asJsonArray(dynamic x) => x?.cast<Map<String, dynamic>>() ?? [];

Map<String, dynamic> asMap(dynamic x) => x ?? {};

Future<void> tick() async => await Future.delayed(const Duration(seconds: 1));
