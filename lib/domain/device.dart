import 'package:idm_client/domain/pos.dart';

///
/// Overview info about Device
class Device {
  final String id;
  final String name;
  final String details;
  final Pos pos;
  final double size;
  const Device({
    required this.id,
    required this.name,
    required this.pos,
    required this.size,
    required this.details,
  });
}

