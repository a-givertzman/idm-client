///
/// A container for errors.
class Failure {
  ///
  /// A brief descriprion of the error.
  final String message;
  ///
  /// An optional child error that provides additional information.
  final Failure? child;
  ///
  /// Creates a new instance of [Failure] with the given [message] and optional [child] error.
  Failure(this.message, {this.child});
  ///
  /// Returns a string representation of this error, including [message] and nested [child] errors.
  @override
  String toString() {
    return 'Failure: $message \n\t↳$child';
  }
}