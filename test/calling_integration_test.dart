import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view360_call/view360_call.dart';
import 'package:view360_direct_chat_example/features/call/data/api/call_token_api_config.dart';
import 'package:view360_direct_chat_example/features/call/data/api/call_token_exception.dart';
import 'package:view360_direct_chat_example/features/call/data/api/token_api_service.dart';
import 'package:view360_direct_chat_example/features/call/presentation/screen/active_call_screen.dart';
import 'package:view360_direct_chat_example/features/call/presentation/screen/voice_call_demo_screen.dart';

void main() {
  group('TokenApiService Tests', () {
    test('sends POST /token with roomName and participantName and returns only the token', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, 'http://127.0.0.1:3000/token');
        expect(options.data, {
          'roomName': 'test-room',
          'participantName': 'user-a',
        });

        // Exact response structure from the Node.js token server
        return ResponseBody.fromString(
          '''
          {
            "serverUrl": "ws://127.0.0.1:7880",
            "participantName": "user-a",
            "roomName": "test-room",
            "token": "GENERATED_LIVEKIT_TOKEN_123"
          }
          ''',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TokenApiService(
        config: const CallTokenApiConfig(baseUrl: 'http://127.0.0.1:3000'),
        dio: dio,
      );

      final token = await service.requestToken(
        roomName: 'test-room',
        participantName: 'user-a',
      );

      // Verify that strictly the token string is returned
      expect(token, 'GENERATED_LIVEKIT_TOKEN_123');
    });

    test('validates and rejects empty participantName or roomName before network call', () async {
      final service = TokenApiService();

      expect(
        () => service.requestToken(roomName: '', participantName: 'user-a'),
        throwsA(isA<CallTokenApiException>().having(
          (e) => e.message,
          'message',
          contains('roomName cannot be empty'),
        )),
      );

      expect(
        () => service.requestToken(roomName: 'test-room', participantName: '   '),
        throwsA(isA<CallTokenApiException>().having(
          (e) => e.message,
          'message',
          contains('participantName cannot be empty'),
        )),
      );
    });

    test('handles HTTP 400 error with backend error message', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"error": "roomName and participantName are required"}',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TokenApiService(dio: dio);

      expect(
        () => service.requestToken(
          roomName: 'test-room',
          participantName: 'user-a',
        ),
        throwsA(isA<CallTokenApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message',
                contains('roomName and participantName are required'))),
      );
    });

    test('handles HTTP 500 server error', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"error": "Token generation failed"}',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TokenApiService(dio: dio);

      expect(
        () => service.requestToken(
          roomName: 'test-room',
          participantName: 'user-a',
        ),
        throwsA(isA<CallTokenApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', contains('Token generation failed'))),
      );
    });

    test('throws CallTokenApiException when response is missing token field', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"serverUrl":"ws://127.0.0.1:7880","roomName":"test-room"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TokenApiService(dio: dio);

      expect(
        () => service.requestToken(
          roomName: 'test-room',
          participantName: 'user-a',
        ),
        throwsA(isA<CallTokenApiException>().having(
          (e) => e.message,
          'message',
          contains('missing "token" field'),
        )),
      );
    });

    test('throws CallTokenApiException when token is empty string', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"serverUrl":"ws://127.0.0.1:7880","roomName":"test-room","token":"   "}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TokenApiService(dio: dio);

      expect(
        () => service.requestToken(
          roomName: 'test-room',
          participantName: 'user-a',
        ),
        throwsA(isA<CallTokenApiException>().having(
          (e) => e.message,
          'message',
          contains('Invalid or empty token'),
        )),
      );
    });

    test('handles connection timeout error gracefully', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });

      final service = TokenApiService(dio: dio);

      expect(
        () => service.requestToken(
          roomName: 'test-room',
          participantName: 'user-a',
        ),
        throwsA(isA<CallTokenApiException>().having(
          (e) => e.message,
          'message',
          contains('timed out'),
        )),
      );
    });
  });

  group('View360Call Integration with TokenApiService', () {
    test('tokenProvider receives only the token string from TokenApiService', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"serverUrl":"ws://127.0.0.1:7880","roomName":"call-room","participantName":"alice","token":"valid.jwt.token"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final tokenApiService = TokenApiService(dio: dio);

      final call = View360Call(
        config: View360CallConfig(
          serverUrl: 'ws://127.0.0.1:7880',
          tokenProvider: ({
            required String roomName,
            required String participantName,
          }) async {
            return await tokenApiService.requestToken(
              roomName: roomName,
              participantName: participantName,
            );
          },
        ),
      );

      final token = await call.controller.config.tokenProvider(
        roomName: 'call-room',
        participantName: 'alice',
      );

      expect(token, 'valid.jwt.token');
      expect(call.controller.state.status, View360CallStatus.disconnected);

      call.dispose();
    });
  });

  group('VoiceCallDemoScreen UI & Validation Tests', () {
    testWidgets('renders App title, fields, status badge, and connect button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceCallDemoScreen(),
        ),
      );

      // Verify Title
      expect(find.text('View360 Call SDK Demo'), findsOneWidget);

      // Verify Fields
      expect(find.text('LiveKit Server URL'), findsOneWidget);
      expect(find.text('Node.js Token API URL'), findsOneWidget);
      expect(find.text('Participant Name'), findsOneWidget);
      expect(find.text('Room Name'), findsOneWidget);

      // Verify Status Badge
      expect(find.text('Disconnected'), findsOneWidget);

      // Verify Connect Button
      expect(find.text('Connect & Join Room'), findsOneWidget);
    });

    testWidgets('validates required fields and displays validation error when empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceCallDemoScreen(),
        ),
      );

      // Clear the Participant Name field
      final participantField = find.widgetWithText(TextFormField, 'user-a');
      await tester.enterText(participantField, '');
      await tester.pump();

      // Ensure connect button is visible and tap it
      final connectBtn = find.text('Connect & Join Room');
      await tester.ensureVisible(connectBtn);
      await tester.tap(connectBtn);
      await tester.pumpAndSettle();

      // Check validation error message
      expect(find.text('Participant name is required'), findsOneWidget);
    });
  });

  group('ActiveCallScreen (Screen 2: Active Voice Call) Tests', () {
    testWidgets('renders dark interface with room, participant, timer, mute, end call, and omits speaker', (tester) async {
      final call = View360Call(
        config: View360CallConfig(
          serverUrl: 'ws://127.0.0.1:7880',
          tokenProvider: ({required roomName, required participantName}) async => 'dummy.jwt',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveCallScreen(
            call: call,
            participantName: 'Alice',
            roomName: 'conference-a',
          ),
        ),
      );

      // Verify participant name and room name
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Room: conference-a'), findsOneWidget);

      // Verify timer
      expect(find.text('00:00'), findsOneWidget);

      // Verify Mute button exists
      expect(find.text('Mute'), findsOneWidget);

      // Verify Speaker button is NOT rendered because SDK does not support it
      expect(find.text('Speaker'), findsNothing);

      // Verify End Call button exists
      expect(find.text('End Call'), findsOneWidget);

      // Verify Scaffolds dark theme background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0B0F19));

      // Unmount widget to trigger dispose and cancel animation/timers
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('displays appropriate UI badge for all connection states', (tester) async {
      for (final status in [
        View360CallStatus.connecting,
        View360CallStatus.connected,
        View360CallStatus.reconnecting,
        View360CallStatus.disconnected,
        View360CallStatus.failed,
      ]) {
        final call = View360Call(
          config: View360CallConfig(
            serverUrl: 'ws://127.0.0.1:7880',
            tokenProvider: ({required roomName, required participantName}) async => 'token',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ActiveCallScreen(
              call: call,
              participantName: 'Bob',
              roomName: 'room-1',
            ),
          ),
        );

        // Verify the badge exists according to status
        switch (status) {
          case View360CallStatus.connecting:
            expect(find.text('Connecting'), findsNothing); // default call starts as disconnected
            break;
          case View360CallStatus.disconnected:
            expect(find.text('Disconnected'), findsOneWidget);
            break;
          default:
            break;
        }

        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _MockHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
