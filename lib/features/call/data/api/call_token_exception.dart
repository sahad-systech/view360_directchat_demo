/// Exception thrown when requesting a LiveKit token from the backend fails.
class CallTokenApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? details;

  const CallTokenApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'CallTokenApiException (HTTP $statusCode): $message';
    }
    return 'CallTokenApiException: $message';
  }
}

