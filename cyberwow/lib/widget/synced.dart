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

import 'dart:collection';

import '../state.dart';
import '../config.dart' as config;
import '../helper.dart';
import '../logging.dart';

Widget summary(BuildContext context, SyncedState state) {
  final height = state.height.toString();
  final onFire = state.getTransactionPool.length >= 10;
  final onFireNotice = onFire ? ' 🔥' : '';
  final poolLength = state.getTransactionPool.length;
  final poolLengthNotice = poolLength > 1 ? '[${poolLength}] ' : '';
  final txNotice = state.getTransactionPool.isEmpty ?
    '' : poolLengthNotice + state.getTransactionPool.first['id    '].substring(0, 6) + ' ...';

  return Container
  (
    padding: EdgeInsets.only(bottom: 10.0),
    child: Align
    (
      alignment: Alignment.center,
      child: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          Spacer
          (
            flex: 17,
          ),
          Image.asset
          ('assets/wownero_symbol.png',
            height: 220,
          ),
          Spacer
          (
            flex: 7,
          ),
          Expanded
          (
            flex: 15,
            child: Row
            (
              children: <Widget>
              [
                Spacer(),
                AnimatedSwitcher
                (
                  duration: Duration(milliseconds: 500),
                  child: Text
                  (
                    height,
                    style: Theme.of(context).textTheme.display1,
                    key: ValueKey<int>(state.height),
                  ),
                ),
                AnimatedSwitcher
                (
                  duration: Duration(milliseconds: 500),
                  child: Text
                  (
                    onFireNotice,
                    style: TextStyle
                    (
                      fontSize: 25,
                    ),
                    key: ValueKey<int>(onFire ? 0 : 1),
                  ),
                ),
                Spacer(),
              ]
            )
          ),
          AnimatedSwitcher
          (
            duration: Duration(milliseconds: 500),
            child: Text
            (
              txNotice,
              style: Theme.of(context).textTheme.body2,
              key: ValueKey<int>(poolLength),
            ),
          ),
          Spacer
          (
            flex: 1,
          ),
          SizedBox
          (
            height: 20.0,
            width: 20.0,
            child: (state.connected) ?
            Container() :
            CircularProgressIndicator
            (
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget rpcView(BuildContext context, String title, String body) {
  return Container
  (
    padding: const EdgeInsets.all(10.0),
    child: Align
    (
      alignment: Alignment.topLeft,
      child: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          Expanded
          (
            flex: 1,
            child: SingleChildScrollView
            (
              scrollDirection: Axis.vertical,
              child: Column
              (
                children: <Widget>
                [

                  Container(
                    height: 0,
                    margin: const EdgeInsets.only(bottom: 15),
                  ),
                  Text
                  (
                    title,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  Container(
                    height: 1,
                    color: Theme.of(context).primaryColor,
                    margin: const EdgeInsets.only(bottom: 20, top: 20),
                  ),
                  Text
                  (
                    body,
                    style: Theme.of(context).textTheme.body2,
                  )
                ],
              )
            )
          )
        ],
      ),
    ),
  );
}

Widget getInfo(BuildContext context, SyncedState state) => rpcView(context, 'info', state.getInfoCache);
Widget syncInfo(BuildContext context, SyncedState state) => rpcView(context, 'sync info', pretty(state.syncInfo));

Widget getTransactionPool(BuildContext context, SyncedState state) {
  final pool = state.getTransactionPool;
  const minimalLength = 6;
  final subTitle = pool.length < minimalLength ? '' : ' ‹${pool.length}›';
  return rpcView(context, 'tx pool' + subTitle, state.getTransactionPoolCache);
}

Widget getConnections(BuildContext context, SyncedState state) {
  final peers = state.getConnections;
  const minimalLength = 6;
  final subTitle = peers.length < minimalLength ? '' : ' ‹${peers.length}›';
  return rpcView(context, 'peers' + subTitle, state.getConnectionsCache);
}



Widget terminalView(BuildContext context, String title, SyncedState state) {
  final input = TextFormField
  (
    controller: state.textController,
    textInputAction: TextInputAction.next,
    autofocus: true,
    autocorrect: false,
    decoration:
    InputDecoration
    (
      // border: UnderlineInputBorder // OutlineInputBorder
      // (
      // ),
      // hintText: 'WOW',
      enabledBorder: UnderlineInputBorder
      (
        borderSide: BorderSide
        (
          color: Theme.of(context).primaryColor,
        ),
      ),
      border: InputBorder.none,
    ),
    onFieldSubmitted: (v) {
      String autoReplace(final String x) {
        final words = x.split(' ');

        if (words.length == 0) {
          return x;
        }

        final head = words.first;
        final tail = words.sublist(1);
        final guessHead = head.replaceAll('-', '_');

        return [ guessHead, ...tail ].join(' ');
      }

      final _text = state.textController.text.trim();
      final line = autoReplace(_text);

      if (line.isNotEmpty) {
        log.finer('terminal input: ${line}');
        state.appendInput(line);
        state.textController.clear();
      }
      else {
        state.textController.clear();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    },
  );

  return Container
  (
    // padding: const EdgeInsets.all(10.0),
    child: Align
    (
      alignment: Alignment.topLeft,
      child: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          Expanded
          (
            flex: 1,
            child: SingleChildScrollView
            (
              scrollDirection: Axis.vertical,
              reverse: true,
              child: Column
              (
                children: <Widget>
                [

                  Text
                  (
                    state.stdout.join(),
                    style: Theme.of(context).textTheme.body2,
                  )
                ],
              )
            )
          ),
          Container
          (
            margin: const EdgeInsets.all(10.0),
            child: input,
          ),
        ],
      ),
    ),
  );
}


Widget terminal(BuildContext context, SyncedState state) => terminalView(context, 'terminal', state);

Widget pageView (BuildContext context, SyncedState state) {
  void _onPageChanged(int pageIndex) {
    if (pageIndex != 0) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    state.onPageChanged(pageIndex);
  }

  return PageView (
    controller: state.pageController,
    onPageChanged: _onPageChanged,
    children:
    [
      terminal(context, state),
      summary(context, state),
      getTransactionPool(context, state),
      getConnections(context, state),
      getInfo(context, state),
      // syncInfo(state),
    ],
  );
}

Widget buildSynced(BuildContext context, SyncedState state) {
  return Scaffold
  (
    body: pageView(context, state)
  );
}
