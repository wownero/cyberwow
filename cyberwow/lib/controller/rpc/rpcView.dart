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

import '../../config.dart' as config;

Map<String, dynamic> rpcPeerView(Map<String, dynamic> x) {
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

