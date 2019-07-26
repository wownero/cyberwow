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

import '../../config.dart' as config;
import '../../helper.dart';
import '../../logging.dart';

Future<http.Response> rpc2(String method) async {
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

dynamic jsonDecode(String responseBody) => json.decode(responseBody);

Future<String> rpc2String(String method, {String field}) async {
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
    final result = responseBody['transactions'];
    if (result == null) {
      return [];
    }
    else {
      return result.map
      (
        (x) {
          const _remove =
          [
            'tx_blob',
            'tx_json',
            'last_failed_id_hash',
            'max_used_block_id_hash',
          ];

          return Map.fromIterable
          (
            x.keys.where
            (
              (k) => !_remove.contains(k)
            ),
            value: (k) => x[k],
          ).map
          (
            (k, v) {
              if (k == 'id_hash') {
                return MapEntry(k, v.substring(0, config.hashLength) + '...');
              } else {
                return MapEntry(k, v);
              }
            }
          )
          ;
        }
      ).toList();
    }
  }
}
