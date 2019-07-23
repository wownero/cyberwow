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

import '../state.dart';
import '../config.dart';
import '../helper.dart';

Widget summary(SyncedState state) {
  return Container
  (
    padding: EdgeInsets.only(bottom: 10.0),
    color: config.backgroundColor,
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
            child: AnimatedSwitcher
            (
              duration: Duration(milliseconds: 500),
              child: Text
              (
                '${state.height}',
                style: TextStyle
                (
                  fontFamily: 'RobotoMono',
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: config.textColor,
                ),
                key: ValueKey<int>(state.height),
              )
            )
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

Widget rpcView(String title, String body) {
  return Container
  (
    padding: const EdgeInsets.all(10.0),
    color: config.backgroundColor,
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
                    style: TextStyle
                    (
                      fontFamily: 'RobotoMono',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: config.textColor,
                    ),
                  ),
                  Container(
                    height: 1,
                    color: config.textColor,
                    margin: const EdgeInsets.only(bottom: 20, top: 20),
                  ),
                  Text
                  (
                    body,
                    style: TextStyle
                    (
                      fontFamily: 'RobotoMono',
                      fontSize: 11,
                      color: config.textColor,
                    ),
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

Widget getInfo(SyncedState state) => rpcView('info', state.getInfo);
Widget getConnections(SyncedState state) => rpcView('connections', state.getConnections);
Widget syncInfo(SyncedState state) => rpcView('sync info', state.syncInfo);
Widget getTransactionPool(SyncedState state) =>
  rpcView('transaction pool', pretty(state.getTransactionPool));

Widget pageView (SyncedState state, PageController controller) {
  return PageView (
    controller: controller,
    children:
    [
      getTransactionPool(state),
      summary(state),
      getInfo(state),
      getConnections(state),
      // syncInfo(state),
    ],
  );
}

Widget buildSynced(BuildContext context, SyncedState state, PageController controller) {
  return Scaffold
  (
    body: pageView(state, controller)
  );
}
