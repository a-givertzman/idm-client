import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/error/failure.dart';

///
/// Testing [Failure]
void main() {
  Log.initialize(level: LogLevel.all);
  const log = Log('Test:Failure');
  group('Failure', () {
    test('.toString()', () {
      final List<(String, String?, String)> testData = [
        (
          'network issue',
          'timeout',
          'Failure: network issue \n\t↳Failure: timeout \n\t↳null'
        ),
        (
          'database error',
          'connection lost',
          'Failure: database error \n\t↳Failure: connection lost \n\t↳null'
        ),
        ('connection error', null, 'Failure: connection error \n\t↳null'),
      ];
      for (final (message, child, target) in testData) {
        final childFailure = child != null ? Failure(child) : null;
        final error = Failure(message, child: childFailure);
        final str = error.toString();
        expect(str, equals(target),
            reason:
                'message: $message, \nchild: $childFailure, \nresult: $str \ntarget: $target');
      }
      log.debug('.test | Done');
    });
  });
}
