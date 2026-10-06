import 'dart:convert';

import 'package:cura/api/api.dart';
import 'package:cura/api/endpoint.dart';
import 'package:cura/services/chatbot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ChatbotResponse.fromJson', () {
    test('keeps every field the API returns', () {
      final response = ChatbotResponse.fromJson({
        'message': 'Take a breath.',
        'user_id': 'user-1',
        'email': 'ada@cura.app',
        'session_id': 'session-1',
        'title': 'Breathing',
      });

      expect(response.message, 'Take a breath.');
      expect(response.userId, 'user-1');
      expect(response.email, 'ada@cura.app');
      expect(response.sessionId, 'session-1');
      expect(response.title, 'Breathing');
    });

    test('uses empty strings when the payload is partial', () {
      final response = ChatbotResponse.fromJson({});

      expect(response.message, isEmpty);
      expect(response.sessionId, isEmpty);
      expect(response.title, isEmpty);
    });
  });

  group('buildApiUri', () {
    test('joins the configured host with the endpoint', () {
      expect(
        buildApiUri(sendUserMessageEndpoint).toString(),
        'http://91.99.143.187:8044/send-message',
      );
    });
  });

  group('ChatbotService', () {
    test('rejects an empty message before calling the network', () async {
      final service = ChatbotService(
        client: MockClient((request) async => http.Response('{}', 200)),
        readAccessToken: () async => 'token',
      );

      expect(
        () => service.sendUserMessage('   '),
        throwsA(
          predicate(
            (error) =>
                error is Exception &&
                error.toString().contains('cannot be empty'),
          ),
        ),
      );
    });

    test('rejects a signed-out user', () async {
      final service = ChatbotService(
        client: MockClient((request) async => http.Response('{}', 200)),
        readAccessToken: () async => null,
      );

      expect(
        () => service.sendUserMessage('Hello'),
        throwsA(
          predicate(
            (error) =>
                error is Exception &&
                error.toString().contains('not logged in'),
          ),
        ),
      );
    });

    test('omits session id on the first message', () async {
      late http.Request captured;
      final service = ChatbotService(
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'message': 'Hello Ada',
              'user_id': 'user-1',
              'email': 'ada@cura.app',
              'session_id': 'session-1',
              'title': 'Hello',
            }),
            200,
          );
        }),
        readAccessToken: () async => 'token-1',
      );

      final response = await service.sendUserMessage('  Hello  ');

      expect(response.message, 'Hello Ada');
      expect(response.sessionId, 'session-1');
      expect(jsonDecode(captured.body), {'user_message': 'Hello'});
      expect(captured.headers['authorization'], 'Bearer token-1');
      expect(captured.url.path, sendUserMessageEndpoint);
    });

    test('sends the session id on a follow-up message', () async {
      late Map<String, dynamic> body;
      final service = ChatbotService(
        client: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'message': 'Still here',
              'session_id': 'session-9',
              'title': 'Follow up',
            }),
            200,
          );
        }),
        readAccessToken: () async => 'token-1',
      );

      final response = await service.sendUserMessage(
        'Continue',
        sessionId: 'session-9',
      );

      expect(body['session_id'], 'session-9');
      expect(response.title, 'Follow up');
    });

    test('surfaces the API detail when the request fails', () async {
      final service = ChatbotService(
        client: MockClient(
          (request) async =>
              http.Response(jsonEncode({'detail': 'Session expired'}), 401),
        ),
        readAccessToken: () async => 'token-1',
      );

      expect(
        () => service.sendUserMessage('Hello'),
        throwsA(
          predicate(
            (error) =>
                error is Exception &&
                error.toString().contains('Session expired'),
          ),
        ),
      );
    });
  });
}
