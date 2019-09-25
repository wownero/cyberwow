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

import 'package:flutter/material.dart';

import 'prototype.dart';

final _theme = ThemeData
(
  brightness: Brightness.dark,

  primaryColor: Colors.green,
  hintColor: Colors.yellow,
  primarySwatch: Colors.green,
  accentColor: Colors.green,
  cursorColor: Colors.green,

  scaffoldBackgroundColor: Colors.black,

  fontFamily: 'RobotoMono',

  textTheme: TextTheme
  (
    display1: TextStyle
    (
      fontSize: 35,
      fontWeight: FontWeight.bold,
    ),
    subhead: TextStyle
    (
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    body2: TextStyle
    (
      fontSize: 11,
    ),
  ).apply
  (
    bodyColor: Colors.green,
    displayColor: Colors.green,
  ),

  // cursorColor: config.c.textColor,
  // inputDecorationTheme: InputDecorationTheme
  // (
  //   focusedBorder: UnderlineInputBorder
  //   (
  //     borderSide: BorderSide(color: config.c.textColor)
  //   )
  // )
);


const Set<String> _commands =
{
  'alt_chain_info',
  'bc_dyn_stat0s',
  'check_blockchain_pruning',
  'flush_txpool',
  'hard_fork_info',
  'hide_hr',
  'in_peers',
  'is_key_image_spent',
  'limit_down',
  'limit_up',
  'mining_status',
  'out_peers',
  'output_histogram',
  'pop_blocks',
  'print_bc',
  'print_block',
  'print_cn',
  'print_coinbase_tx_sum',
  'print_height',
  'print_net_stats',
  'print_pl',
  'print_pl_stats',
  'print_pool',
  'print_pool_sh',
  'print_pool_stats',
  'print_status',
  'print_tx',
  'prune_blockchain',
  'relay_tx',
  'set_log',
  'show_hr',
  'start_mining',
  'start_save_graph',
  'stop_daemon',
  'stop_mining',
  'stop_save_graph',
  'sync_info',
};

final config = CryptoConfig
(
  'wownerod',
  'wownerod',
  'Follow the white rabbit.',
  70,
  _theme,
  34568,
  _commands,
  [
    '--prune-blockchain',
    '--max-concurrency=1',
    '--fast-block-sync=1',
    '--block-sync-size=5',
  ],
  '[1337@cyberwow]: ',
);
