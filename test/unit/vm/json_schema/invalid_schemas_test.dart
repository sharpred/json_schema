// Copyright 2013-2018 Workiva Inc.
//
// Licensed under the Boost Software License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This software or document includes material copied from or derived
// from JSON-Schema-Test-Suite (https://github.com/json-schema-org/JSON-Schema-Test-Suite),
// Copyright (c) 2012 Julian Berman, which is licensed under the following terms:
//
//     Copyright (c) 2012 Julian Berman
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.

library json_schema.test_invalid_schemas;

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'package:json_schema/json_schema.dart';
import 'package:json_schema/vm.dart';

final Logger _logger = new Logger('test_invalid_schemas');

void main([List<String> args]) {
  configureJsonSchemaForVm();

  if (args?.isEmpty == true) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print('${r.loggerName} [${r.level}]:\t${r.message}'));
    Logger.root.level = Level.OFF;
  }

  final Directory testSuiteFolder =
      new Directory('./test/invalid_schemas/draft4');

  testSuiteFolder.listSync().forEach((testEntry) {
    final String shortName = path.basename(testEntry.path);
    group('Invalid schema (draft4): ${shortName}', () {
      if (testEntry is File) {
        final List tests = json.decode((testEntry).readAsStringSync());
        tests.forEach((testObject) {
          final schemaData = testObject['schema'];
          final description = testObject['description'];

          test(description, () async {
            final catchException = expectAsync1((e) {
              _logger.info('Caught expected $e');
              if (!(e is FormatException)) {
                _logger.info(
                    '${shortName} threw an unexpected error type of ${e.runtimeType}');
              }
              expect(e is FormatException, true);
            });

            try {
              await JsonSchema.createSchemaAsync(schemaData,
                  schemaVersion: SchemaVersion.draft4);
              fail('Schema is expected to be invalid, but was not.');
            } catch (e) {
              catchException(e);
            }
          });
        });
      }
    });
  });
}
