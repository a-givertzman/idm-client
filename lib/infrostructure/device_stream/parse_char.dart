// import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_option.dart';
import 'package:idm_client/domain/types/bytes.dart';
import 'package:idm_client/infrostructure/device_stream/message_parse.dart';
///
/// Extracting exact char by it's code from the input bytes
/// - Used to identify a start of the message for example
class ParseChar implements MessageParse<Bytes, Option<Bytes>> {
  // final _log = const Log("ParseChar");
  final int _char;
  Option _value = const None();
  ///
  /// Returns ParseChar new instance
  /// - [char] - some byte identyfies a start of the message,
  /// - for start by default 22 can be used
  ParseChar({
    required int char,
  }):
    _char = char;
  ///
  /// Returns ParseChar new instance
  /// - With default `Start` symbol SYN = 22
  ParseChar.start():
    _char = 22;
  ///
  /// Returns Ok if `char` has been parsed or Err
  @override
  Option<Bytes> parse(Bytes bytes) {
    switch (_value) {
      case Some():
        return Some(bytes);
      case None():
        final pos = bytes.indexWhere((b) => b == _char);
        if (pos >= 0) {
          _value = const Some(null);
          return Some(bytes.sublist(pos + 1));
        } else {
          return const None();
        }
    }
  }
  //
  //
  @override
  void reset() {
    _value = const None();    
  }
}