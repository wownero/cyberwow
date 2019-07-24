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

import 'rpc/rpc.dart' as rpc;
import '../config.dart' as config;
import '../logging.dart';

Future<bool> isConnected() async {
  final _outPeers = await rpc.outgoingConnectionsCount();
  final _inPeers = await rpc.incomingConnectionsCount();

  log.finest('outPeers: ${_outPeers}');
  log.finest('inPeers: ${_inPeers}');
  return _outPeers + _inPeers > 0;
}

Future<bool> isSynced() async {
  final _targetHeight = await rpc.targetHeight();
  final _height = await rpc.height();
  return _targetHeight >= 0 && _targetHeight <= _height && _height > config.minimumHeight;
}

Future<bool> isNotSynced() async {
  final _targetHeight = await rpc.targetHeight();
  final _height = await rpc.height();
  return _targetHeight > _height;
}
