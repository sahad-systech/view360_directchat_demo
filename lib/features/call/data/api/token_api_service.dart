import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'call_token_api_config.dart';
import 'call_token_exception.dart';

/// API service responsible for communicating with the Node.js LiveKit token backend.
///
/// Follows secure client practices:
/// - Never exposes or stores the LiveKit API secret.
/// - Validates the backend response strictly.
/// - Returns only the JWT string to satisfy the SDK's `tokenProvider`.
class TokenApiService {
  final CallTokenApiConfig config;
  final Dio _dio;

  TokenApiService({this.config = const CallTokenApiConfig(), Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: config.connectTimeout,
              receiveTimeout: config.receiveTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  /// Requests a LiveKit JWT token from the Node.js backend.
  ///
  /// Sends [roomName] and [participantName] in a `POST /token` request.
  /// Validates the response and returns only the JWT [token].
  Future<String> requestToken({
    required String roomName,
    required String participantName,
  }) async {
    final trimmedRoom = roomName.trim();
    final trimmedParticipant = participantName.trim();

    if (trimmedRoom.isEmpty) {
      throw const CallTokenApiException('roomName cannot be empty.');
    }
    if (trimmedParticipant.isEmpty) {
      throw const CallTokenApiException('participantName cannot be empty.');
    }

    final endpoint = config.fullEndpointUrl;

    try {
      final response = await _dio.post(
        endpoint,
        data: {'roomName': trimmedRoom, 'participantName': trimmedParticipant},
      );
      log(response.toString());
      return _validateAndExtractToken(response);
    } on DioException catch (dioError) {
      throw _handleDioError(dioError, endpoint);
    } catch (e) {
      if (e is CallTokenApiException) rethrow;
      throw CallTokenApiException('Unexpected error requesting token: $e');
    }
  }

  /// Strictly validates the HTTP response and returns the extracted JWT token.
  String _validateAndExtractToken(Response response) {
    if (response.statusCode != 200) {
      throw CallTokenApiException(
        'Server returned non-200 status code.',
        statusCode: response.statusCode,
      );
    }

    final dynamic rawData = response.data;
    if (rawData == null) {
      throw const CallTokenApiException(
        'Token server returned an empty response body.',
        statusCode: 200,
      );
    }

    Map<String, dynamic> data;
    if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        } else {
          throw const FormatException('Decoded body is not a JSON object.');
        }
      } catch (e) {
        throw CallTokenApiException(
          'Failed to parse token response as JSON: $e',
          statusCode: 200,
          details: rawData,
        );
      }
    } else {
      throw CallTokenApiException(
        'Unexpected response type (${rawData.runtimeType}).',
        statusCode: 200,
      );
    }

    // Validate the token field
    if (!data.containsKey('token')) {
      throw CallTokenApiException(
        'Token server response missing "token" field.',
        statusCode: 200,
        details: data,
      );
    }

    final token = data['token'];
    if (token is! String || token.trim().isEmpty) {
      throw CallTokenApiException(
        'Invalid or empty token received from token server.',
        statusCode: 200,
        details: token,
      );
    }

    return token.trim();
  }

  /// Maps Dio HTTP exceptions to a user-friendly [CallTokenApiException].
  CallTokenApiException _handleDioError(
    DioException dioError,
    String endpoint,
  ) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;

    String? serverErrorMessage;
    if (responseData is Map && responseData['error'] != null) {
      serverErrorMessage = responseData['error'].toString();
    } else if (responseData is String && responseData.isNotEmpty) {
      serverErrorMessage = responseData;
    }

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CallTokenApiException(
          'Connection to token server timed out ($endpoint).',
          statusCode: statusCode,
        );

      case DioExceptionType.badResponse:
        return CallTokenApiException(
          serverErrorMessage ??
              'Token server rejected the request with HTTP $statusCode.',
          statusCode: statusCode,
          details: responseData,
        );

      case DioExceptionType.connectionError:
        return CallTokenApiException(
          'Could not connect to token server at $endpoint. Ensure your Node.js server is running.',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const CallTokenApiException('Token request was cancelled.');

      case DioExceptionType.badCertificate:
        return const CallTokenApiException(
          'Invalid SSL certificate from token server.',
        );

      case DioExceptionType.unknown:
      default:
        return CallTokenApiException(
          serverErrorMessage ??
              dioError.message ??
              'Unknown network error occurred while obtaining token.',
          statusCode: statusCode,
        );
    }
  }
}
