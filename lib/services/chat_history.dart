import 'package:cura/models/chat_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:cura/models/chat_session.dart';

class ChatHistoryService {
  ChatHistoryService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<ChatSessionSummary>> fetchChatSessions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final response = await _supabase
        .from('session_histpry')
        .select('id,title')
        .eq('user_id', user.id);

    final sessions = <ChatSessionSummary>[];

    for (final item in response) {
      final data = Map<String, dynamic>.from(item as Map);
      final sessionId = data['id'] as String? ?? '';
      if (sessionId.isEmpty) continue;

      final latestTurn = await _fetchLatestTurn(sessionId);
      sessions.add(
        ChatSessionSummary(
          sessionId: sessionId,
          title: normalizeChatTitle(data['title'] as String?),
          preview: latestTurn?.preview ?? emptyChatPreview,
          lastActivity: latestTurn?.createdAt,
        ),
      );
    }

    return sortChatSessions(sessions);
  }

  Future<List<ChatHistoryTurn>> fetchSessionTurns(String sessionId) async {
    final response = await _supabase
        .from('messages_history')
        .select('user_message,bot_message,created_at')
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return response
        .map(
          (item) =>
              ChatHistoryTurn.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> deleteSession(String sessionId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _supabase
        .from('session_histpry')
        .delete()
        .eq('id', sessionId)
        .eq('user_id', user.id);
  }

  Future<_LatestTurnPreview?> _fetchLatestTurn(String sessionId) async {
    final response = await _supabase
        .from('messages_history')
        .select('user_message,bot_message,created_at')
        .eq('session_id', sessionId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    final data = Map<String, dynamic>.from(response as Map);
    return _LatestTurnPreview(
      preview: messagePreview(
        userMessage: data['user_message'] as String? ?? '',
        botMessage: data['bot_message'] as String? ?? '',
      ),
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? ''),
    );
  }
}

class _LatestTurnPreview {
  const _LatestTurnPreview({required this.preview, required this.createdAt});

  final String preview;
  final DateTime? createdAt;
}
