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

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../config.dart' as config;
import '../../../helper.dart';
import '../../../logging.dart';

Future<http.Response> rpcHTTP(final String method) async {
  final url = 'http://${config.host}:${config.c.port}/json_rpc';

  final body = json.encode
  (
    {
      'jsonrpc': '2.0',
      'method': method,
    }
  );

  try {
    final response = await http.post
    ( url,
      body: body
    );
    return response;
  }
  catch (e) {
    log.warning(e);
    return null;
  }
}

dynamic jsonDecode(final String responseBody) => json.decode(responseBody);

Future<dynamic> rpc(final String method, {final String field}) async {
  final response = await rpcHTTP(method);

  if (response == null) return null;

  if (response.statusCode != 200) {
    return null;
  } else {
    final _body = await compute(jsonDecode, response.body);
    final _result = _body['result'];
    if (_result == null) return null;

    final _field = field == null ? _result : _result[field];

    return _field;
  }
}

Future<String> rpcString(final String method, {final String field}) async {
  final _field = await rpc(method, field: field);
  return pretty(_field);
}
