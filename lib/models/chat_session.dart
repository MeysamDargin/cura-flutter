class ChatSessionSummary {
  const ChatSessionSummary({
    required this.sessionId,
    required this.title,
    required this.preview,
    required this.lastActivity,
  });

  final String sessionId;
  final String title;
  final String preview;
  final DateTime? lastActivity;
}

class ChatHistoryTurn {
  const ChatHistoryTurn({
    required this.userMessage,
    required this.botMessage,
    required this.createdAt,
  });

  final String userMessage;
  final String botMessage;
  final DateTime? createdAt;

  factory ChatHistoryTurn.fromJson(Map<String, dynamic> json) {
    return ChatHistoryTurn(
      userMessage: json['user_message'] as String? ?? '',
      botMessage: json['bot_message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

const emptyChatTitle = 'New Chat';
const emptyChatPreview = 'No messages yet';

String normalizeChatTitle(String? title) {
  final trimmed = title?.trim() ?? '';
  return trimmed.isEmpty ? emptyChatTitle : trimmed;
}

String messagePreview({
  required String userMessage,
  required String botMessage,
}) {
  final bot = botMessage.trim();
  final user = userMessage.trim();
  final preview = bot.isNotEmpty ? bot : user;
  return preview.isEmpty ? emptyChatPreview : preview;
}

int compareChatSessions(ChatSessionSummary first, ChatSessionSummary second) {
  final firstTime = first.lastActivity;
  final secondTime = second.lastActivity;

  if (firstTime == null && secondTime == null) {
    return second.title.compareTo(first.title);
  }
  if (firstTime == null) return 1;
  if (secondTime == null) return -1;
  return secondTime.compareTo(firstTime);
}

List<ChatSessionSummary> sortChatSessions(List<ChatSessionSummary> sessions) {
  final sorted = List<ChatSessionSummary>.from(sessions);
  sorted.sort(compareChatSessions);
  return sorted;
}
