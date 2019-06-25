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

Future<http.Response> rpc(String method) async {
  var url = '';
  if (kReleaseMode) {
    url = 'http://127.0.0.1:34568/json_rpc';
  } else {
    url = 'http://192.168.10.100:34568/json_rpc';
  }

  final body = json.encode
  (
    {
      'jsonrpc': '2.0',
      'id': '0',
      'method': method,
    }
  );

  var response = await http.post
  ( url,
    body: body
  );

  return response;
}

Future<http.Response> syncInfo() async {
  return rpc('sync_info');
}

Future<int> targetHeight() async {
  var response = await syncInfo();

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return -1;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["target_height"];
  }
}

Future<int> height() async {
  var response = await syncInfo();

  // print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    return -1;
  } else {
    final responseBody = json.decode(response.body)['result'];
    return responseBody["height"];
  }
}
