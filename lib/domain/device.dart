import 'dart:ui';

import 'package:idm_client/domain/pos.dart';

///
/// Overview info about Device
class Device {
  final String id;
  final String title;
  final String details;
  final Pos pos;
  final Size size;
  const Device({
    required this.id,
    required this.title,
    required this.pos,
    required this.size,
    required this.details,
  });
}

