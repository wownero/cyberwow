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
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'dart:io';
import 'dart:async';

import 'config.dart' as config;
import 'logic/controller/process/run.dart' as process;
import 'logging.dart';
import 'state.dart' as state;
import 'widget.dart' as widget;

void main() {
  Logger.root.level = kReleaseMode ? Level.INFO : Level.FINE;
  Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  runApp(CyberWOW_App());
}

class CyberWOW_App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp
    (
      title: 'CyberWOW',
      theme: config.c.theme,
      darkTheme: config.c.theme,
      home: CyberWOW_Page(title: 'CyberWOW'),
    );
  }
}

class CyberWOW_Page extends StatefulWidget {
  CyberWOW_Page({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CyberWOW_PageState createState() => _CyberWOW_PageState();
}

class _CyberWOW_PageState extends State<CyberWOW_Page> with WidgetsBindingObserver
{
  // AppState _state = LoadingState("init...");
  static const _channel = const MethodChannel('send-intent');

  state.AppState _state;
  AppLifecycleState _notification = AppLifecycleState.resumed;

  bool _exiting = false;

  final StreamController<String> inputStreamController = StreamController();

  Future<String> getInitialIntent() async {
    final text = await _channel.invokeMethod('getInitialIntent');
    log.fine('getInitialIntent: ${text}');
    return text;
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    log.fine('app cycle: ${state}');
    setState(() { _notification = state; });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setState(final state.AppState newState) {
    setState
    (
      () => _state = newState
    );
  }

  AppLifecycleState _getNotification() {
    return _notification;
  }

  bool _isExiting() {
    return _exiting;
  }

  state.AppState _getState() {
    return _state;
  }

  Future<void> buildStateMachine(final state.BlankState _blankState) async {
    final loadingText = config.c.splash;
    state.LoadingState _loadingState = await _blankState.next(loadingText);
    state.SyncingState _syncingState = await _loadingState.next();

    final _initialIntent = await getInitialIntent();
    final _userArgs = _initialIntent
    .trim()
    .split(RegExp(r"\s+"))
    .where((x) => !x.isEmpty)
    .toList();

    if (!_userArgs.isEmpty) {
      log.info('user args: ${_userArgs}');
    }

    final syncing = process
    .runBinary
    (
      config.c.outputBin,
      input: inputStreamController.stream,
      shouldExit: _isExiting,
      userArgs: _userArgs,
    )
    .asBroadcastStream();

    await _syncingState.next(inputStreamController.sink, syncing);

    bool exited = false;
    bool validState = true;

    while (validState && !exited) {
      switch (_state.runtimeType) {
        case state.ExitingState: {
          await (_state as state.ExitingState).wait();
          log.finer('exit state wait done');
          exited = true;
        }
        break;

        case state.SyncedState:
          await (_state as state.SyncedState).next();
          break;

        case state.ReSyncingState:
          await (_state as state.ReSyncingState).next();
          break;

        default: validState = false;
      }
    }

    log.finer('state machine finished');

    if (exited) {
      log.finer('popping navigator');
      // SystemNavigator.pop();
      exit(0);
    } else {
      log.severe('Reached invalid state!');
      exit(1);
    }
  }

  @override
  void initState() {
    super.initState();
    log.fine("CyberWOW_PageState initState");

    WidgetsBinding.instance.addObserver(this);

    final state.AppHook _appHook = state.AppHook(_setState, _getNotification, _isExiting);
    final state.BlankState _blankState = state.BlankState(_appHook);
    _state = _blankState;

    buildStateMachine(_blankState);
  }

  Future<bool> _exitApp(final BuildContext context) async {
    log.info("CyberWOW_PageState _exitApp");
    WidgetsBinding.instance.removeObserver(this);

    _exiting = true;
    inputStreamController.sink.add('exit');

    await Future.delayed(const Duration(seconds: 5));

    // the process controller should call exit(0) for us
    log.warning('Daemon took too long to shut down!');
    exit(1);
  }

  @override
  Widget build(final BuildContext context) {
    return WillPopScope
    (
      onWillPop: () => _exitApp(context),
      child: widget.build(context, _state),
    );
  }
}
