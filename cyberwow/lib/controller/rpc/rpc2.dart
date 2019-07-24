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

import '../../config.dart';
import '../../helper.dart';

Future<http.Response> rpc2(String method) async {
  final url = 'http://${host}:${config.port}/${method}';

  var response;
  try {
    response = await http.post
    ( url,
    );
  }
  catch (e) {
    // print(e);
  }

  return response;
}

Future<String> rpc2String(String method, {String field}) async {
  final response = await rpc2(method);

  if (response == null) return '';

  if (response.statusCode != 200) {
    return '';
  } else {
    final _body= json.decode(response.body);
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
    var result = responseBody['transactions'];
    if (result == null) {
      return [];
    }
    else {
      result.forEach
      (
        (tx) {
          tx.remove('tx_blob');
          tx.remove('tx_json');
          tx.remove('last_failed_id_hash');
          tx.remove('max_used_block_id_hash');
        }
      );
      return result;
    }
  }
}
