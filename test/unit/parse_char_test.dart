import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:idm_client/domain/types/bytes.dart';
import 'package:idm_client/infrostructure/device_stream/parse_char.dart';
///
///
const int syn = 22;
const restart = true;
const keepGo = false;
///
/// Testing [ParseChar].parse
void main() {
  group('FieldSyn.parse', () {
    test('.parse()', () async {
      ParseChar parseSyn = ParseChar.start();
      final List<(int, bool, Bytes, Option<Bytes>)> testData = [
        (01,  keepGo, [ 11,  12, syn, 13, 14], const Some([13, 14])),
        (02,  keepGo, [ 21,  23,  24, 25, 26], const Some([21,  23,  24, 25, 26])),
        (03, restart, [ 31, syn,  33, 34, 35], const Some([33, 34, 35])),
        (04, restart, [ 41,  43,  44, 45, 46], const None()),
        (05,  keepGo, [syn,  53,  55, 55, 56], const Some([53,  55, 55, 56])),
        (06,  keepGo, [ 61,  62,  63, 64, 65], const Some([61,  62,  63, 64, 65])),
      ];
      for (final (step, restart, bytes, target) in testData) {
        if (restart) {
          // parseSyn = ParseChar.def();
          parseSyn.reset();
        }
        switch (parseSyn.parse(bytes)) {
          case Some<List<int>>(value: Bytes resultBytes):
            expect(
              target.isSome(),
              true,
              reason: 'step: $step \n result: ${true} \n target: ${target.isSome()}',
            );
            expect(
              listEquals(resultBytes, target.unwrap()),
              true,
              reason: 'step: $step \n result: $resultBytes \n target: ${target.unwrap()}',
            );
          case None():
            expect(
              target.isNone(),
              true,
              reason: 'step: $step \n result: ${true} \n target: ${target.isNone()}',
            );
        }
      }
    });
  });
}