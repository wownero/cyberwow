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

import '../../config.dart' as config;
import '../../helper.dart';
import '../../logging.dart';

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

Future<http.Response> getTransactionPool() async => rpc2('get_transaction_pool');

Future<List<dynamic>> getTransactionPoolSimple() async {
  final response = await getTransactionPool();

  if (response == null) return [];

  log.finest('getTransactionPoolSimple response: ${response.body}');
  log.finest('Response status: ${response.statusCode}');

  if (response.statusCode != 200) {
    return [];
  } else {
    final responseBody = json.decode(response.body);
    final result = asJsonArray(responseBody['transactions']);
    final _sortedPool = result..sort
    (
      (x, y) {
        final int a = x['receive_time'];
        final int b = y['receive_time'];
        return b.compareTo(a);
      }
    );

    final _decodedPool = await Stream.fromIterable(_sortedPool).asyncMap
    (
      (x) async {
        final String _tx_json = x['tx_json'];
        final _tx_json_decoded = await compute(jsonDecode, _tx_json);

        return {
          ...x,
          ...{'tx_decoded': _tx_json_decoded},
        };
      }
    );

    return _decodedPool.toList();
  }
}
