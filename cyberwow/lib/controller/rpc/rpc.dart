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

int rpcID = 0;

Future<http.Response> rpc(String method) async {
  final url = 'http://${host}:${config.port}/json_rpc';

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

Future<dynamic> rpcDynamic(String method, {String field}) async {
  final response = await rpc(method);

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
  final _field = await rpcDynamic(method, field: field);
  return pretty(_field);
}

Future<http.Response> syncInfo() async => rpc('sync_info');
Future<String> syncInfoString() async => rpcString('sync_info');

Future<int> targetHeight() => rpcDynamic('sync_info', field: 'target_height');

Future<int> height() async {
  final response = await syncInfo();

  if (response == null) return -1;

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return -1;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["height"];
  }
}


Future<http.Response> getInfo() async => rpc('get_info');
Future<String> getInfoString() async => rpcString('get_info');

Future<bool> offline() async {
  final response = await getInfo();

  if (response == null) return true;

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return true;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["offline"];
  }
}

Future<int> outgoingConnectionsCount() async {
  final response = await getInfo();

  if (response == null) return -1;

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return -1;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["outgoing_connections_count"];
  }
}

Future<int> incomingConnectionsCount() async {
  final response = await getInfo();

  if (response == null) return -1;

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return -1;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["incoming_connections_count"];
  }
}

// Future<http.Response>> getConnections() async => rpc('get_connections', field: 'connections');
Future<String> getConnectionsString() async => rpcString('get_connections', field: 'connections');


