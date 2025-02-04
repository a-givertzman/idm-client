import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/point/point_type.dart';

///
/// Testing [PointType]
void main() {
  Log.initialize(level: LogLevel.all);
  const log = Log('Test:PointType');
  group('PointType', () {
    test('.fromStr()', () {
      final List<(String, PointType)> testData = [
        (
          'int',
          PointType.int,
        ),
        (
          'bool',
          PointType.bool,
        ),
        (
          ' ',
          PointType.string,
        ),
        (
          'string',
          PointType.string,
        ),
        (
          'real',
          PointType.real,
        ),
        (
          'double',
          PointType.double,
        ),
        (
          'unknown',
          PointType.string,
        ),
      ];
      for (final (string, target) in testData) {
        final type = PointType.fromStr(string);
        expect(type, equals(target),
            reason: 'string: $string, \nresult: $type \ntarget: $target');
      }
      log.debug('.test | Done');
    });
    test('.toStr()', () {
      final List<(String, PointType)> testData = [
        (
          'int',
          PointType.int,
        ),
        (
          'bool',
          PointType.bool,
        ),
        (
          'string',
          PointType.string,
        ),
        (
          'real',
          PointType.real,
        ),
        (
          'double',
          PointType.double,
        ),
      ];
      for (final (target, type) in testData) {
        final str = type.toStr();
        expect(str, equals(target),
            reason: 'type: $type, \nresult: $str \ntarget: $target');
      }
      log.debug('.test | Done');
    });
  });
}
