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
    T Function(RunningState) useRunningState,
  )
  {
    if (this is BlankState) {
      return useBlankState(this);
    }
    if (this is LoadingState) {
      return useLoadingState(this);
    }
    if (this is RunningState) {
      return useRunningState(this);
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


  Future<RunningState> next(Stream<String> loadingProgress, String status) async {
    Future<void> showBanner() async {
      var chars = [];
      banner.runes.forEach((int rune) {
          final c = new String.fromCharCode(rune);
          chars.add(c);
      });

      for (String char in chars) {
        append(char);
        await Future.delayed(const Duration(milliseconds: 70), () => "1");
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

    final outputBinExists = await binaryExists(outputBin);
    if (outputBinExists) {
      await load();
    }
    else {
      await Future.wait([load(), showBanner()]);
    }

    RunningState _next = RunningState(setState, status);
    setState(_next);
    return _next;
  }
}

class RunningState extends HookedState {
  String status;

  RunningState(f, this.status) : super (f);

  void append(String msg) {
    this.status += msg;
    setState(this);
  }

  Future<void> next(Stream<String> runningOutput) async {
    print("RunningState.next");

    await for (var line in runningOutput) {
      append(line);
      print(line);
    }
  }
}
