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

import '../../../helper.dart';
import '../../../config.dart' as config;
import '../../../logging.dart';
import '../../interface/rpc/rpc2.dart' as rpc2;

Future<http.Response> getTransactionPool() async => rpc2.rpc2('get_transaction_pool');

Map<String, String> txInOutCache = {};

Future<List<Map<String, dynamic>>> getTransactionPoolSimple() async {
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
        if (txInOutCache.length > config.maxPoolTxSize) {
          txInOutCache = {};
        }

        final _txid = x['id_hash'];

        if (txInOutCache[_txid] == null) {
          final String _tx_json = x['tx_json'];
          final _tx_json_decoded = await compute(jsonDecode, _tx_json);

          final _inOut =
          {
            'vin': _tx_json_decoded['vin'].length,
            'vout': _tx_json_decoded['vout'].length,
          };

          final _inOutString = _inOut['vin'].toString() + '/' + _inOut['vout'].toString();

          txInOutCache[_txid] = _inOutString;
          log.fine('cached tx_json in pool for: ${_txid}');
        }

        return {
          ...x,
          ...{'i/o': txInOutCache[_txid]},
        };
      }
    );

    return _decodedPool.toList();
  }
}
