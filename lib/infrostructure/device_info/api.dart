import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/error/failure.dart';

///
/// TODO: Type doc
class Api {
  final String address;
  ///
  /// TODO: Type doc
  const Api(this.address);
  ///
  /// TODO: Type doc
  Future<Result<Map<String, dynamic>, Failure>> fetch(String id) async {
    return Future.value(const Ok({}));
  }
}
