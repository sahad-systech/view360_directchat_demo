import 'api/call_token_api_config.dart';
import 'api/token_api_service.dart';

export 'api/call_token_api_config.dart';
export 'api/call_token_exception.dart';
export 'api/token_api_service.dart';

/// Service adapter providing backward-compatible access to [TokenApiService].
class TokenService {
  final TokenApiService _apiService;

  TokenService({TokenApiService? apiService})
      : _apiService = apiService ?? TokenApiService();

  /// Requests a token from the backend.
  Future<String> fetchToken({
    required String tokenServerUrl,
    required String roomName,
    required String participantName,
  }) {
    final customService = TokenApiService(
      config: CallTokenApiConfig(baseUrl: tokenServerUrl),
    );
    return customService.requestToken(
      roomName: roomName,
      participantName: participantName,
    );
  }

  /// Direct token request using default configuration.
  Future<String> requestToken({
    required String roomName,
    required String participantName,
  }) {
    return _apiService.requestToken(
      roomName: roomName,
      participantName: participantName,
    );
  }
}
