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

int rpcID = 0;

Future<http.Response> rpcHTTP(String method) async {
  final url = 'http://${config.host}:${config.c.port}/json_rpc';

  rpcID += 1;

  final body = json.encode
  (
    {
      'jsonrpc': '2.0',
      'id': rpcID.toString(),
      'method': method,
    }
  );

  var response;
  try {
    response = await http.post
    ( url,
      body: body
    );
  }
  catch (e) {
    // print(e);
  }

  return response;
}

Future<dynamic> rpc(String method, {String field}) async {
  final response = await rpcHTTP(method);

  if (response == null) return null;

  if (response.statusCode != 200) {
    return null;
  } else {
    final _result = json.decode(response.body)['result'];
    final _field = field == null ? _result : _result[field];

    return _field;
  }
}

Future<String> rpcString(String method, {String field}) async {
  final _field = await rpc(method, field: field);
  return pretty(_field);
}

Future<http.Response> syncInfo() => rpc('sync_info');
Future<String> syncInfoString() => rpcString('sync_info');

Future<dynamic> targetHeight() => rpc('sync_info', field: 'target_height');
Future<dynamic> height() => rpc('sync_info', field: 'height');


Future<http.Response> getInfo() => rpc('get_info');
Future<String> getInfoString() => rpcString('get_info');

Future<dynamic> offline() => rpc('get_info', field: 'offline');

Future<dynamic> outgoingConnectionsCount() => rpc('get_info', field: 'outgoing_connections_count');
Future<dynamic> incomingConnectionsCount() => rpc('get_info', field: 'incoming_connections_count');

// Future<http.Response>> getConnections() async => rpcHTTP('get_connections', field: 'connections');
Future<List<dynamic>> getConnectionsSimple() async {
  final List<dynamic> _connections = await rpc('get_connections', field: 'connections');

  return _connections.map
  (
    (x) {
      const _remove =
      [
        // 'tx_blob',
        // 'tx_json',
        // 'last_failed_id_hash',
        // 'max_used_block_id_hash',
      ];

      return x.map
      (
        (k, v) {
          if (k == 'connection_id') {
            return MapEntry(k, v.substring(0, 12) + '...');
          } else {
            return MapEntry(k, v);
          }
        }
      );
    }
  ).toList();
}


