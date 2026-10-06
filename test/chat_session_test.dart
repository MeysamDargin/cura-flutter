import 'package:cura/models/chat_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHistoryTurn.fromJson', () {
    test('reads a complete turn', () {
      final turn = ChatHistoryTurn.fromJson({
        'user_message': 'Hello',
        'bot_message': 'Hi there',
        'created_at': '2026-10-06T12:00:00.000Z',
      });

      expect(turn.userMessage, 'Hello');
      expect(turn.botMessage, 'Hi there');
      expect(turn.createdAt, isNotNull);
    });

    test('falls back when fields are missing', () {
      final turn = ChatHistoryTurn.fromJson({});

      expect(turn.userMessage, isEmpty);
      expect(turn.botMessage, isEmpty);
      expect(turn.createdAt, isNull);
    });
  });

  group('chat session helpers', () {
    test('normalizes blank titles', () {
      expect(normalizeChatTitle(null), emptyChatTitle);
      expect(normalizeChatTitle('  '), emptyChatTitle);
      expect(normalizeChatTitle(' Morning '), 'Morning');
    });

    test('prefers the assistant preview', () {
      expect(
        messagePreview(userMessage: 'Hello', botMessage: '  Welcome  '),
        'Welcome',
      );
      expect(messagePreview(userMessage: 'Hello', botMessage: ' '), 'Hello');
      expect(
        messagePreview(userMessage: ' ', botMessage: ' '),
        emptyChatPreview,
      );
    });

    test('orders recent sessions first and untitled ones by title', () {
      final older = ChatSessionSummary(
        sessionId: 'old',
        title: 'Older',
        preview: 'a',
        lastActivity: DateTime(2026, 10, 1),
      );
      final newer = ChatSessionSummary(
        sessionId: 'new',
        title: 'Newer',
        preview: 'b',
        lastActivity: DateTime(2026, 10, 6),
      );
      final alpha = ChatSessionSummary(
        sessionId: 'a',
        title: 'Alpha',
        preview: 'c',
        lastActivity: null,
      );
      final bravo = ChatSessionSummary(
        sessionId: 'b',
        title: 'Bravo',
        preview: 'd',
        lastActivity: null,
      );

      final sorted = sortChatSessions([older, alpha, newer, bravo]);

      expect(sorted.map((session) => session.sessionId), [
        'new',
        'old',
        'b',
        'a',
      ]);
    });
  });
}
