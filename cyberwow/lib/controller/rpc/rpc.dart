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
import 'rpcView.dart' as rpcView;
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

  return cleanKey(rpcView.getInfoView(_getInfo));
}

Future<String> getInfoString() => rpcString('get_info');

Future<bool> offline() => rpc('get_info', field: 'offline').then(asBool);

Future<int> outgoingConnectionsCount() =>
  rpc('get_info', field: 'outgoing_connections_count').then(asInt);
Future<int> incomingConnectionsCount() =>
  rpc('get_info', field: 'incoming_connections_count').then(asInt);

Future<List<dynamic>> getConnectionsSimple() async {
  final _connections = await rpc('get_connections', field: 'connections').then(asJsonArray);

  const minActiveTime = 8;
  final _activeConnections = _connections.where((x) => x['live_time'] > minActiveTime);

  final _sortedConn = _activeConnections.toList()..sort
  (
    (x, y) {
      final int a = x['live_time'];
      final int b = y['live_time'];
      return a.compareTo(b);
    }
  );

  return _sortedConn.map(rpcView.getConnectionView).map(cleanKey).toList();
}


