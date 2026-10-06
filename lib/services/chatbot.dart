import 'dart:convert';

import 'package:cura/api/api.dart';
import 'package:cura/api/endpoint.dart';
import 'package:cura/models/chatbot_response.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:cura/models/chatbot_response.dart';

typedef AccessTokenReader = Future<String?> Function();

class ChatbotService {
  ChatbotService({http.Client? client, AccessTokenReader? readAccessToken})
    : _client = client ?? http.Client(),
      _readAccessToken = readAccessToken;

  final http.Client _client;
  final AccessTokenReader? _readAccessToken;

  Future<ChatbotResponse> sendUserMessage(
    String userMessage, {
    String? sessionId,
  }) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) {
      throw Exception('user_message cannot be empty.');
    }

    final accessToken = await _accessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('User is not logged in.');
    }

    final body = <String, dynamic>{'user_message': trimmed};
    if (sessionId != null && sessionId.isNotEmpty) {
      body['session_id'] = sessionId;
    }

    final response = await _client.post(
      buildApiUri(sendUserMessageEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response format.');
      }
      return ChatbotResponse.fromJson(decoded);
    }

    throw Exception(_errorMessage(response));
  }

  Future<String?> _accessToken() {
    final reader = _readAccessToken;
    if (reader != null) return reader();
    return Future.value(
      Supabase.instance.client.auth.currentSession?.accessToken,
    );
  }

  String _errorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Request failed with status code ${response.statusCode}.';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {}

    return 'Request failed with status code ${response.statusCode}.';
  }
}
