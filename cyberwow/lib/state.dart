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
import 'dart:io';
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'controller/helper.dart';
import 'config.dart';

abstract class AppState {
  T use<T>
  (
    T Function(BlankState) useBlankState,
    T Function(LoadingState) useLoadingState,
    T Function(SyncingState) useSyncingState,
    T Function(SyncedState) useSyncedState,
  )
  {
    if (this is BlankState) {
      return useBlankState(this);
    }
    if (this is LoadingState) {
      return useLoadingState(this);
    }
    if (this is SyncingState) {
      return useSyncingState(this);
    }
    if (this is SyncedState) {
      return useSyncedState(this);
    }
    throw Exception('Invalid state');
  }
}

typedef SetStateFunc = void Function(AppState);

class HookedState extends AppState {
  final SetStateFunc setState;
  HookedState(this.setState);
}

class BlankState extends HookedState {
  BlankState(f) : super (f);

  Future<LoadingState> next(String status) async {
    LoadingState _next = LoadingState(setState, status);

    setState(_next);
    return _next;
  }
}

class LoadingState extends HookedState {
  String banner;
  String status = '';

  LoadingState(f, this.banner) : super (f);

  void append(String msg) {
    this.status += msg;
    setState(this);
  }


  Future<SyncingState> next(Stream<String> loadingProgress, String status) async {
    Future<void> showBanner() async {
      var chars = [];
      banner.runes.forEach((int rune) {
          final c = new String.fromCharCode(rune);
          chars.add(c);
      });

      for (String char in chars) {
        append(char);
        await Future.delayed(Duration(milliseconds: config.splashDelay), () => "1");
      }

      await Future.delayed(const Duration(seconds: 2), () => "1");
    }

    Future<void> load() async {
      print("LoadingState.next");
      await for (var line in loadingProgress) {
        // append(line);
        print(line);
      }
    }

    final outputBinExists = await binaryExists(config.outputBin);
    if (outputBinExists) {
      await load();
    }
    else {
      await Future.wait([load(), showBanner()]);
    }

    SyncingState _next = SyncingState(setState, status);
    setState(_next);
    return _next;
  }
}

class SyncingState extends HookedState {
  String status;

  SyncingState(f, this.status) : super (f);

  void append(String msg) {
    this.status += msg;
    setState(this);
  }

  Future<SyncedState> next(Stream<String> processOutput) async {
    print("SyncingState.next");

    await for (var line in processOutput) {
      append(line);
      print(line);
      // print('hi');

      final _targetHeight = await targetHeight();
      print('target_height: ${_targetHeight}');

      if (_targetHeight == 0) break;
    }

    SyncedState _next = SyncedState(setState, processOutput);
    setState(_next);
    return _next;
  }
}

class SyncedState extends HookedState {
  Stream<String> processOutput;

  SyncedState(f, this.processOutput) : super (f);

  Future<void> next() async {
    print("SyncedState.next");

    while (true) {
      final _targetHeight = await targetHeight();
      print('target_height: ${_targetHeight}');

      await Future.delayed(const Duration(seconds: 2), () => "1");
    }
  }
}
