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

Widget helloPage(SyncedState state) {
  return Container
  (
    child: Text('HelloPage'),
  );
}

Widget pageView (SyncedState state, PageController controller) {
  return PageView (
    controller: controller,
    children:
    [
      summary(state),
      helloPage(state),
    ],
  );
}

Widget buildSynced(BuildContext context, SyncedState state, PageController controller) {
  return Scaffold
  (
    body: pageView(state, controller)
  );
}
