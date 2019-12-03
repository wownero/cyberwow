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

import 'config/prototype.dart';
import 'config/cyberwow.dart' as cryptoConfig;

final c = cryptoConfig.config;

const arch = 'arm64';
// const arch = 'x86_64';
const minimumHeight = 118361;

const isEmu = arch == 'x86_64';
const emuHost = '192.168.10.100';

const host = isEmu ? emuHost : '127.0.0.1';

const int hashViewBlock = 6;
const stdoutLineBufferSize = 100;

