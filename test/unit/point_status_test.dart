import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/point/point_status.dart';

///
/// Testing [Status]
void main() {
  Log.initialize(level: LogLevel.all);
  const log = Log('Test:Status');
  group('Status', () {
    test('.fromInt()', () {
      final List<(int, Status)> testData = [
        (
          0,
          Status.ok,
        ),
        (
          10,
          Status.invalid,
        ),
        (
          0,
          Status.ok,
        ),
        (
          -1,
          Status.invalid,
        ),
        (
          11,
          Status.invalid,
        ),
      ];
      for (final (value, target) in testData) {
        final status = Status.fromInt(value);
        expect(status, equals(target),
            reason: 'value: $value, \nresult: $status \ntarget: $target');
      }
      log.debug('.test | Done');
    });
  });
  test('.toInt()', () {
    final List<(int, Status)> testData = [
      (
        0,
        Status.ok,
      ),
      (
        10,
        Status.invalid,
      ),
      (
        0,
        Status.ok,
      ),
    ];
    for (final (target, status) in testData) {
      final value = status.toInt();
      expect(value, equals(target),
          reason: 'status: $status, \nresult: $value \ntarget: $target');
    }
    log.debug('.test | Done');
  });
}
