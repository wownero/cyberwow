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

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../config.dart' as config;
import '../../../helper.dart';
import '../../../logging.dart';

Future<http.Response> rpc2(final String method) async {
  final url = 'http://${config.host}:${config.c.port}/${method}';

  try {
    final response = await http.post
    ( url,
    );
    return response;
  }
  catch (e) {
    log.warning(e);
    return null;
  }
}

dynamic jsonDecode(final String responseBody) => json.decode(responseBody);

Future<String> rpc2String(final String method, {final String field}) async {
  final response = await rpc2(method);

  if (response == null) return '';

  if (response.statusCode != 200) {
    return '';
  } else {
    final _body = await compute(jsonDecode, response.body);
    final _field = field == null ? _body: _body[field];

    return pretty(_field);
  }
}
