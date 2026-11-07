import '../../../../core/constants/app_constants.dart';

/// Configuration for the Node.js LiveKit Token Server.
/// Keeps backend network endpoints and timeouts separate from UI code.
class CallTokenApiConfig {
  final String baseUrl;
  final String tokenEndpoint;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const CallTokenApiConfig({
    this.baseUrl = AppConstants.defaultTokenServerUrl,
    this.tokenEndpoint = '/token',
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
  });

  /// Full endpoint URI for requesting tokens.
  String get fullEndpointUrl {
    final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final cleanPath = tokenEndpoint.startsWith('/')
        ? tokenEndpoint
        : '/$tokenEndpoint';
    return '$cleanBase$cleanPath';
  }

  CallTokenApiConfig copyWith({
    String? baseUrl,
    String? tokenEndpoint,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    return CallTokenApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
    );
  }
}

