import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:idm_client/domain/types/bytes.dart';
import 'package:idm_client/domain/point/point.dart';
import 'package:idm_client/domain/point/point_status.dart';
import 'package:idm_client/domain/point/point_type.dart';
import 'package:idm_client/infrostructure/device_stream/connect.dart';
import 'package:idm_client/infrostructure/device_stream/message.dart';
import 'package:ext_rw/src/api_client/message/field_id.dart';
import 'package:ext_rw/src/api_client/message/field_kind.dart';
import 'package:ext_rw/src/api_client/message/field_syn.dart';
import 'package:ext_rw/src/api_client/message/field_size.dart';
import 'package:ext_rw/src/api_client/message/field_data.dart';
import 'package:ext_rw/src/api_client/message/message_build.dart';
import 'package:ext_rw/src/api_client/message/parse_data.dart';
import 'package:ext_rw/src/api_client/message/parse_id.dart';
import 'package:ext_rw/src/api_client/message/parse_kind.dart';
import 'package:ext_rw/src/api_client/message/parse_size.dart';
import 'package:ext_rw/src/api_client/message/parse_syn.dart';

///
/// setup constants
const int syn = 22;
const restart = true;
const keepGo = false;

///
/// Testing [Connect].parse
void main() {
  Log.initialize(level: LogLevel.all);
  const log = Log('Test:Message');
  group('MessageBuild.build', () {
    test('.build()', () async {
      final (addr, port) = ('127.0.0.1', 1238);
      Connect connect = Connect(
        addr: addr,
        port: port,
      );
      final message = Message(connect: connect);
      Point buildPoint<T>(String name, PointType type, value) {
        return Point<T>(
          name: name,
          type: type,
          value: value,
          status: Status.ok,
          timestamp: "2024-12-26T12:00:00Z",
        );
      }
      final List<(int, Point)> testData = [
        (01, buildPoint('Device01', PointType.int, 101)),
        (02, buildPoint('Device02', PointType.double, 102.02)),
        (03, buildPoint('Device03', PointType.double, 103.033)),
        (04, buildPoint('Device04', PointType.string, '104.04')),
      ];
      final server = await ServerSocket.bind(addr, port);
      StreamSubscription<Bytes>? srvSubscription;
      server.first.then((srvSocket) {
        int received = 0;
        srvSocket.setOption(SocketOption.tcpNoDelay, true);
        log.debug('.server.first | srvSocket: $srvSocket');
        final message = ParseData(
          field: ParseSize(
            size: FieldSize.def(),
            field: ParseKind(
              field: ParseId(
              id: FieldId.def(),
                field: ParseSyn.def(),
              ),
            ),
          ),
        );
        final messageBuild = MessageBuild(
          syn: FieldSyn.def(),
          id: FieldId.def(),
          kind: FieldKind.bytes,
          size: FieldSize.def(),
          data: FieldData([]),
        );
        srvSubscription = srvSocket.listen((event) async {

          Bytes? input = event;
          bool isSome = true;
          while (isSome) {
            log.debug('.srvSocket.listen | input: $input');
            // _log.debug('.listen.onData | input (${input?.length}): $input');
            switch (message.parse(input)) {
              case Some<(FieldId, FieldKind, FieldSize, Bytes)>(value: (final id, final kind, final size, final bytes)):
                log.debug('.listen.onData | Parsed | id: $id,  kind: $kind,  size: $size, bytes: $bytes');
                await Future.delayed(const Duration(milliseconds: 500), () async {
                  final reply = messageBuild.build(bytes, id: id.id);
                  received++;
                  srvSocket.add(reply);
                  srvSocket.flush();
                  if (received >= testData.length) {
                    await Future.delayed(const Duration(milliseconds: 1000));
                    log.warn('.srvSocket.listen | Exit...');
                    srvSubscription?.cancel();
                    srvSocket.close();
                  }
                });
                log.debug('.listen.onData | Microtask started');
                input = null;
              case None():
                log.debug('.listen.onData | Parsed | None');
                isSome = false;
            }
          }

        });
      }, onError: (err) {
        log.warn('.srvSocket.listen | Error: $err');
      }).whenComplete(() {
        log.debug('.srvSocket.listen | Exit - Ok');
      });
      await Future.delayed(const Duration(milliseconds: 300));
      for (final (step, event) in testData) {
        message.add(event);
        message.flush();
        await Future.delayed(const Duration(milliseconds: 1000));
        log.debug('.test | step: $step,  sent event: $event');
      }
      final received = <Point>[];
      await for (final event in message.stream) {
        received.add(event);
        log.debug('.test | received events $event');

        if (received.length >= testData.length) {
          log.debug('.listen | received: $received');
          connect.close();
          server.close();
          break;
        }
      }
      // void compare(Point expected, Point actual) {
      //   expect(actual.name, equals(expected.name));
      //   expect(actual.type, equals(expected.type));
      //   expect(actual.value, equals(expected.value));
      //   expect(actual.status, equals(expected.status));
      //   expect(actual.timestamp, equals(expected.timestamp));
      // }

      // for (int i = 0; i < received.length; i++) {
      //   compare(testData[i].$2, received[i]);
      // }
      log.debug('.test | Done');
      // expect(
      //   listEquals(result, target),
      //   true,
      //   reason: 'step: $step \n result: $result \n target: $target',
      // );
    });
  });
}
