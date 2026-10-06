class ChatbotResponse {
  const ChatbotResponse({
    required this.message,
    required this.userId,
    required this.email,
    required this.sessionId,
    required this.title,
  });

  final String message;
  final String userId;
  final String email;
  final String sessionId;
  final String title;

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      message: json['message'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}
