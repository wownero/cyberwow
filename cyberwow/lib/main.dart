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

import 'state.dart';
import 'config.dart' as config;
import 'logging.dart';
import 'controller/process/deploy.dart' as process;
import 'controller/process/run.dart' as process;
import 'widget/loading.dart' as widget;
import 'widget/blank.dart' as widget;
import 'widget/syncing.dart' as widget;
import 'widget/synced.dart' as widget;
import 'widget/resyncing.dart' as widget;
import 'widget/exiting.dart' as widget;

void main() {
  Logger.root.level = kReleaseMode ? Level.INFO : Level.FINE;
  Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  runApp(CyberWOW_App());
}

class CyberWOW_App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

  AppState _state;
  AppLifecycleState _notification = AppLifecycleState.resumed;

  bool _exiting = false;

  final StreamController<String> inputStreamController = StreamController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log.fine('app cycle: ${state}');
    setState(() { _notification = state; });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setState(AppState newState) {
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

  AppState _getState() {
    return _state;
  }


  void _updateLoading(LoadingState state, final String msg) {
    log.fine('updateLoading: ' + msg);
  }

  Future<void> buildStateMachine(final BlankState _blankState) async {
    final loadingText = config.c.splash;
    LoadingState _loadingState = await _blankState.next(loadingText);

    final binName = config.c.outputBin;
    final resourcePath = 'native/output/' + config.arch + '/' + binName;
    final bundle = DefaultAssetBundle.of(context);
    final loading = process.deployBinary(bundle, resourcePath, binName);

    SyncingState _syncingState = await _loadingState.next(loading, '');

    final syncing = process
    .runBinary(binName, _isExiting, input: inputStreamController.stream)
    .asBroadcastStream();

    HookedState _syncedNextState = await _syncingState.next(inputStreamController.sink, syncing);

    var exited = false;

    if (_syncedNextState is SyncedState) {
      SyncedState _syncedState = _syncedNextState;
      await _syncedState.next();
    } else {
      ExitingState _exitingState = _syncedNextState;
      await _exitingState.wait();
      exited = true;
    }

    var validState = true;
    while (validState && !exited) {
      await _getState().use
      (
        (s) => validState = false,
        (s) => validState = false,
        (s) => validState = false,
        (s) => s.next(),
        (s) => s.next(),
        (s) async {
          await s.wait();
          log.finer('exit state wait done');
          exited = true;
        }
      );
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

    final BlankState _blankState = BlankState(_setState, _getNotification, _isExiting);
    _state = _blankState;

    buildStateMachine(_blankState);
  }

  Future<bool> _exitApp(BuildContext context) async {
    log.info("CyberWOW_PageState _exitApp");
    WidgetsBinding.instance.removeObserver(this);

    _exiting = true;
    inputStreamController.sink.add('exit');

    await Future.delayed(const Duration(seconds: 5), () => null);

    // the process controller should call exit(0) for us
    log.warning('Daemon took too long to shut down!');
    exit(1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope
    (
      onWillPop: () => _exitApp(context),
      child: _state.use
      (
        (s) => widget.buildBlank(context, s),
        (s) => widget.buildLoading(context, s),
        (s) => widget.buildSyncing(context, s),
        (s) => widget.buildSynced(context, s),
        (s) => widget.buildReSyncing(context, s),
        (s) => widget.buildExiting(context, s),
      ),
    );
  }
}
