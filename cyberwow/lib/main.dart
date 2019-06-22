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

import 'dart:io';
import 'dart:async';

import 'state.dart';
import 'config.dart';
import 'controller/loading.dart';
import 'controller/running.dart';
import 'widget/loading.dart';
import 'widget/blank.dart';
import 'widget/running.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      title: 'Flutter Demo',
      theme: ThemeData
      (
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'CyberWOW'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  int _counter = 0;
  // AppState _state = LoadingState("init...");

  AppState _state;

  void _setState(AppState newState) {
    setState
    (
      () => _state = newState
    );
  }

  void _updateLoading(LoadingState state, String msg) {
    print('updateLoading: ' + msg);
  }

  Future<void> buildStateMachine(BlankState _blankState) async {
    final loadingText = config.splash;
    LoadingState _loadingState = await _blankState.next(loadingText);

    final binName = config.outputBin;
    final resourcePath = 'native/output/' + arch + '/' + binName;
    final bundle = DefaultAssetBundle.of(context);
    final loading = deployBinary(bundle, resourcePath, binName);

    RunningState _runningState = await _loadingState.next(loading, '');

    final running = runBinary(binName);
    await _runningState.next(running);
  }

  @override
  void initState() {
    super.initState();
    print("MyHomePageState initState");

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    BlankState _blankState = BlankState(_setState);
    _state = _blankState;

    buildStateMachine(_blankState);
  }

  Future<bool> _exitApp(BuildContext context) async {
    print("MyHomePageState _exitApp");
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope
    (
      onWillPop: () => _exitApp(context),
      child: _state.use
      (
        (s) => buildBlank(context, s),
        (s) => buildLoading(context, s),
        (s) => buildRunning(context, s),
      ),
    );
  }
}
