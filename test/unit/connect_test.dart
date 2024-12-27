import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:idm_client/domain/types/bytes.dart';
import 'package:idm_client/infrostructure/device_stream/connect.dart';

///
/// setup constants
const int syn = 22;
const restart = true;
const keepGo = false;

///
/// Testing [Connect].parse
void main() {
  Log.initialize(level: LogLevel.all);
  const log = Log('Test:Connect');
  group('MessageBuild.build', () {
    test('.build()', () async {
      final (addr, port) = ('127.0.0.1', 1237);
      Connect connect = Connect(
        addr: addr,
        port: port,
      );
      final List<(int, Bytes)> testData = [
        (
          00,
          [0xDF, 0xDC, 0x1C, 0x35],
        ),
        (
          01,
          [0x76, 0x22, 0x32, 0x14],
        ),
        (
          02,
          [0x0C, 0x68, 0x24, 0xCB],
        ),
        (
          03,
          [0xA2, 0xAC, 0xB7, 0xF2],
        ),
        (
          04,
          [0xFF, 0xFF, 0xFF, 0xFF],
        ),
        (05, [00]),
      ];
      final server = await ServerSocket.bind(addr, port);
      StreamSubscription<Bytes>? srvSubscription;
      server.first.then((srvSocket) {
        log.debug('.server.first | srvSocket: $srvSocket');
        srvSubscription = srvSocket.listen((bytes) {
          log.debug('.srvSocket.listen | bytes: $bytes');
          if (bytes == [00]) {
            log.debug('.srvSocket.listen | Exit...');
            srvSubscription?.cancel();
            srvSocket.close();
          }
          srvSocket.add(bytes);
        });
      }, onError: (err) {
        log.warn('.srvSocket.listen | Error: $err');
      }).whenComplete(() {
        log.debug('.srvSocket.listen | Exit - Ok');
      });
      await Future.delayed(const Duration(milliseconds: 300));
      for (final (step, bytes) in testData) {
        connect.add(bytes);
        // required for splitting the individual messages
        connect.flush();
        log.debug('.test | step: $step,  sent bytes: $bytes');
      }
      final received = [];
      List<int> testDataList = testData.expand((item) => item.$2).toList();
      await for (final bytes in connect.stream) {
        received.add(bytes);
        log.debug('.test | received bytes: $bytes');

        if (bytes.length >= testDataList.length) {
          log.debug('.listen | received: $received');
          connect.close();
          server.close();
          break;
        }
      }
      log.debug('.test | Done');
      // expect(
      //   listEquals(result, target),
      //   true,
      //   reason: 'step: $step \n result: $result \n target: $target',
      // );
    });
  });
}
