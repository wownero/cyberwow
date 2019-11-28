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

import 'package:intl/intl.dart';

import '../../config.dart' as config;
import '../../helper.dart';

Map<String, dynamic> getConnectionView(Map<String, dynamic> x) {
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
        return MapEntry(k, trimHash(v));
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
    for (final k in keys) k: _conn[k]
  };

  final _cleanupConn = _sortedConn..removeWhere
  (
    (k,v) => k == 'pruning_seed' && x[k] == 0
  );

  return _cleanupConn;
}

Map<String, dynamic> simpleHeight(int height, Map<String, dynamic> x) {
  return x.map
  (
    (k, v) {
      if (k == 'height') {
        if (v == 0) {
          return MapEntry(k, '☠');
        }

        else if (v < height) {
          return MapEntry(k, '-${height - v}');
        }

        else if (v == height) {
          return MapEntry(k, '✓');
        }

        else {
          return MapEntry(k, '+${v - height}');
        }
      }
      else {
        return MapEntry(k, v);
      }
    }
  );
}

Map<String, dynamic> getInfoView(Map<String, dynamic> x) {
  const _remove =
  [
    'difficulty_top64',
    'stagenet',
    'testnet',
    'top_hash',
    'update_available',
    'was_bootstrap_ever_used',
    'bootstrap_daemon_address',
    'height_without_bootstrap',
    'wide_cumulative_difficulty',
    'wide_difficulty',
    'cumulative_difficulty_top64',
    'credits',
  ];

  final _filteredInfo = x..removeWhere
  (
    (k,v) => _remove.contains(k)
  );

  final _formattedInfo = _filteredInfo.map
  (
    (k, v) {
      if (k == 'top_block_hash') {
        return MapEntry(k, trimHash(v));
      }


      const sizeField =
      [
        'block_size_limit',
        'block_size_median',
        'block_weight_limit',
        'block_weight_median',
        'difficulty',
        'height',
        'tx_count',
        'cumulative_difficulty',
        'free_space',
        'database_size',
      ];
      if (sizeField.contains(k)) {
        final formatter = NumberFormat.compact();
        return MapEntry(k, formatter.format(v));
      }

      else if (k == 'start_time') {
        final _receive_time = DateTime.fromMillisecondsSinceEpoch(v * 1000);
        final _diff = DateTime.now().difference(_receive_time);

        format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
        return MapEntry('uptime', format(_diff));
      }


      else {
        return MapEntry(k, v);
      }
    }
  );

  return _formattedInfo.map
  (
    (k, v) {
      if (k.contains('_count') && k != 'tx_count') {
        return MapEntry(k.replaceAll('_count', ''), v);
      }

      else {
        return MapEntry(k, v);
      }
    }
  );
}
