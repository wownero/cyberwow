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
import 'controller/rpc.dart' as rpc;
import 'controller/refresh.dart' as refresh;
import 'config.dart';

abstract class AppState {
  T use<T>
  (
    T Function(BlankState) useBlankState,
    T Function(LoadingState) useLoadingState,
    T Function(SyncingState) useSyncingState,
    T Function(SyncedState) useSyncedState,
    T Function(ReSyncingState) useReSyncingState,
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
    if (this is ReSyncingState) {
      return useReSyncingState(this);
    }
    throw Exception('Invalid state');
  }
}

typedef SetStateFunc = void Function(AppState);
typedef GetNotificationFunc = AppLifecycleState Function();

class HookedState extends AppState {
  final SetStateFunc setState;
  final GetNotificationFunc getNotification;
  HookedState(this.setState, this.getNotification);
}

class BlankState extends HookedState {
  BlankState(f, s) : super (f, s);

  Future<LoadingState> next(String status) async {
    LoadingState _next = LoadingState(setState, getNotification, status);

    setState(_next);
    return _next;
  }
}

class LoadingState extends HookedState {
  String banner;
  String status = '';

  LoadingState(f, s, this.banner) : super (f, s);

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
      print("Loading next");
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

    SyncingState _next = SyncingState(setState, getNotification, status);
    setState(_next);
    return _next;
  }
}

class SyncingState extends HookedState {
  String stdout;
  bool synced = false;

  SyncingState(f, s, this.stdout) : super (f, s);

  void append(String msg) {
    this.stdout += msg;
    setState(this);
  }

  Future<SyncedState> next(Stream<String> processOutput) async {
    print("Syncing next");

    Future<void> printStdout() async {
      await for (var line in processOutput) {
        if (synced) break;
        // print('syncing: print stdout loop');



        append(line);
        print(line);
      }
    }

    Future<void> checkSync() async {
      await for (var _targetHeight in refresh.targetHeight(getNotification)) {
        print('syncing: target height ${_targetHeight}');

        final _height = await rpc.height();
        // print('syncing: height ${_height}');

        // final _offline = await rpc.offline();
        // print('syncing: offline ${_offline}');

        final _out_peers = await rpc.outgoing_connections_count();
        // print('syncing: out_peers ${_out_peers}');

        // here doc is wrong, targetHeight could match height when synced
        // potential bug, targetHeight could be smaller then height
        if ((_targetHeight >= 0 && _targetHeight <= _height) && _out_peers > 0) {
          synced = true;
          break;
        }
        // print('syncing: checkSync loop');
      }
    }

    printStdout();
    await checkSync();

    print('syncing: loop exit');

    SyncedState _next = SyncedState(setState, getNotification, stdout, processOutput);
    _next.height = await rpc.height();
    setState(_next);
    return _next;
  }
}

class SyncedState extends HookedState {
  String stdout;
  int height;
  Stream<String> processOutput;
  bool synced = true;

  SyncedState(f, s, this.stdout, this.processOutput) : super (f, s);

  void updateHeight(int h) {
    if (height != h) {
      height = h;
      setState(this);
    }
  }

  Future<ReSyncingState> next() async {
    print("Synced next");

    Future<void> logStdout() async {
      await for (var line in processOutput) {
        if (!synced) break;
        // print('synced: print stdout loop');
        stdout += line;
        print(line);
      }
    }

    logStdout();

    await for (var _targetHeight in refresh.targetHeight(getNotification)) {
      // print('re-sync: target height ${_targetHeight}');

      final _height = await rpc.height();
      // print('re-sync: height ${_height}');

      if (_targetHeight > _height) {
        synced = false;
        break;
      }
      // print('synced loop');
      updateHeight(await rpc.height());
      // print('synced: targetheight: ${_targetHeight}');
      // print('synced: height: ${height}');
    }

    print('synced: loop exit');

    ReSyncingState _next = ReSyncingState(setState, getNotification, stdout, processOutput);
    setState(_next);
    return _next;
  }
}


class ReSyncingState extends HookedState {
  String stdout;
  Stream<String> processOutput;
  bool synced = false;

  ReSyncingState(f, s, this.stdout, this.processOutput) : super (f, s);

  void append(String msg) {
    this.stdout += msg;
    setState(this);
  }

  Future<SyncedState> next() async {
    print("ReSyncing next");

    Future<void> printStdout() async {
      await for (var line in processOutput) {
        if (synced) break;
        // print('re-syncing: print stdout loop');
        append(line);
        print(line);
      }
    }

    Future<void> checkSync() async {
      await for (var _targetHeight in refresh.targetHeight(getNotification)) {
        // print('re-sync: target height ${_targetHeight}');

        final _height = await rpc.height();
        // print('re-sync: height ${_height}');

        if (_targetHeight >= 0 && _targetHeight <= _height) {
          synced = true;
          break;
        }
        // print('re-syncing: checkSync loop');
      }
    }

    printStdout();
    await checkSync();

    print('resync: await exit');
    SyncedState _next = SyncedState(setState, getNotification, stdout, processOutput);
    _next.height = await rpc.height();
    setState(_next);
    return _next;
  }
}
