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

import 'config.dart' as config;

String pretty(dynamic x) {
  final JsonEncoder encoder = JsonEncoder.withIndent('');
  return encoder.convert(x)
         .replaceAll(RegExp(r'^{'), '\n')
         .replaceAll(RegExp(r'["\[\],{}]'), '')
         ;
}

String trimHash(String x) => x.substring(0, config.hashLength) + ' ...';

int asInt(dynamic x) => x?.toInt() ?? 0;

bool asBool(dynamic x) => x ?? false;

List<dynamic> asList(dynamic x) => x ?? [];
List<Map<String, dynamic>> asJsonArray(dynamic x) => x?.cast<Map<String, dynamic>>() ?? [];

Map<String, dynamic> asMap(dynamic x) => x ?? {};
