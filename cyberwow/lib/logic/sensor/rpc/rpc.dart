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

import '../../../helper.dart';
import '../../../logging.dart';
import '../../interface/rpc/rpc.dart';

Future<http.Response> syncInfo() => rpc('sync_info');
Future<String> syncInfoString() => rpcString('sync_info');

Future<int> targetHeight() => rpc('sync_info', field: 'target_height').then(asInt);
Future<int> height() => rpc('sync_info', field: 'height').then(asInt);

Future<http.Response> getInfo() => rpc('get_info');

Future<Map<String, dynamic>> getInfoSimple() async {
  final _getInfo = await rpc('get_info').then(asMap);

  return _getInfo;
}

Future<String> getInfoString() => rpcString('get_info');

Future<bool> offline() => rpc('get_info', field: 'offline').then(asBool);

Future<int> outgoingConnectionsCount() =>
  rpc('get_info', field: 'outgoing_connections_count').then(asInt);
Future<int> incomingConnectionsCount() =>
  rpc('get_info', field: 'incoming_connections_count').then(asInt);

Future<List<Map<String, dynamic>>> getConnectionsSimple() async {
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

  return _sortedConn.toList();
}


