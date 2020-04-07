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

import 'dart:math';

import 'package:intl/intl.dart';

import '../../../config.dart' as config;
import '../../../helper.dart';

Map<String, dynamic> txView(Map<String, dynamic> x) {
  const _remove =
  [
    'tx_blob',
    // 'tx_json',
    'last_failed_id_hash',
    'max_used_block_id_hash',
    // fields not useful for noobs
    'last_relayed_time',
    'kept_by_block',
    'double_spend_seen',
    'relayed',
    'do_not_relay',
    'last_failed_height',
    'max_used_block_height',
    'weight',
    // 'blob_size',
  ];

  final _filteredTx = x..removeWhere
  (
    (k,v) => _remove.contains(k)
  );

  final _formattedTx = _filteredTx.map
  (
    (k, v) {
      switch (k) {
        case 'id_hash':
          return MapEntry('id', trimHash(v));
        case 'blob_size':
          return MapEntry('size', (v / 1024).toStringAsFixed(2) + ' kB');
        case 'fee': {
          final formatter = NumberFormat.currency
          (
            symbol: '',
            decimalDigits: 2,
          );
          return MapEntry(k, formatter.format(v / pow(10, 11)) + ' ⍵');
        }
        case 'receive_time': {
          final _receive_time = DateTime.fromMillisecondsSinceEpoch(v * 1000);
          final _diff = DateTime.now().difference(_receive_time);

          format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
          return MapEntry('age', format(_diff));
        }
        default:
          return MapEntry(k, v);
      }
    }



  );

  final List<String> keys =
  [
    'id',
    'age',
    'fee',
    'i/o',
    'size',
  ]
  .where((k) => _formattedTx.keys.contains(k))
  .toList();

  final _sortedTx = {
    for (final k in keys) k: _formattedTx[k]
  };

  return _sortedTx;
}
