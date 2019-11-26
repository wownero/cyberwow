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

Future<http.Response> rpcHTTP(final String method) async {
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
    final _field = field == null ? _result : _result[field];

    return _field;
  }
}

Future<String> rpcString(final String method, {final String field}) async {
  final _field = await rpc(method, field: field);
  return pretty(_field);
}

Future<http.Response> syncInfo() => rpc('sync_info');
Future<String> syncInfoString() => rpcString('sync_info');

Future<int> targetHeight() => rpc('sync_info', field: 'target_height').then(asInt);
Future<int> height() => rpc('sync_info', field: 'height').then(asInt);

Future<http.Response> getInfo() => rpc('get_info');

Future<Map<String, dynamic>> getInfoSimple() async {
  final _getInfo = await rpc('get_info').then(asMap);

  return _getInfo.map
  (
    (k, v) {
      if (k == 'top_block_hash') {
        return MapEntry(k, v.substring(0, config.hashLength) + '...');
      } else {
        return MapEntry(k, v);
      }
    }
  );
}

Future<String> getInfoString() => rpcString('get_info');

Future<bool> offline() => rpc('get_info', field: 'offline').then(asBool);

Future<int> outgoingConnectionsCount() =>
  rpc('get_info', field: 'outgoing_connections_count').then(asInt);
Future<int> incomingConnectionsCount() =>
  rpc('get_info', field: 'incoming_connections_count').then(asInt);

Future<List<dynamic>> getConnectionsSimple() async {
  final _connections = await rpc('get_connections', field: 'connections').then(asList);

  return _connections.map
  (
    (x) {
      const _remove =
      [
        'address_type',
        'connection_id',
        'host',
        'ip',
        'local_ip',
        'localhost',
        'peer_id',
        'port',
        'recv_count',
        'rpc_port',
        'send_count',
        'support_flags',

        // 'avg_download',
        // 'avg_upload',
        // 'current_download',
        // 'current_upload',
        'rpc_credits_per_hash',
        'state',
        'recv_idle_time',
        'send_idle_time',
        'incoming',
      ];

      final _filteredConn = x..removeWhere
      (
        (k,v) => _remove.contains(k)
      );

      final _conn = _filteredConn.map
      (
        (k, v) {
          if (k == 'connection_id') {
            return MapEntry(k, v.substring(0, config.hashLength) + '...');
          }

          const speedField =
          [
            'avg_download',
            'avg_upload',
            'current_download',
            'current_upload',
          ];
          if (speedField.contains(k)) {
            return MapEntry(k, '${v} kB/s');
          }

          else if (k == 'live_time') {
            final _duration = Duration(seconds: v);
            format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
            return MapEntry(k, format(_duration));
          }

          else {
            return MapEntry(k, v);
          }
        }
      );

      final List<String> keys =
      [
        'address',
        'height',
        'live_time',
        'current_download',
        'current_upload',
        'avg_download',
        'avg_upload',
        'pruning_seed',
      ]
      .where((k) => _conn.keys.contains(k))
      .toList();

      final _sortedConn = {
        for (var k in keys) k: _conn[k]
      };

      return _sortedConn;
    }
  ).toList();
}


