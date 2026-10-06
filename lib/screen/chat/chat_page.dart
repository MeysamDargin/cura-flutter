import 'package:cura/screen/history/history_page.dart';
import 'package:cura/services/chat_history.dart';
import 'package:cura/services/chatbot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.initialUserMessage,
    this.initialSessionId,
    this.initialTitle = 'New Chat',
  }) : assert(
         initialUserMessage != null || initialSessionId != null,
         'Either initialUserMessage or initialSessionId must be provided.',
       );

  final String? initialUserMessage;
  final String? initialSessionId;
  final String initialTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  final ChatHistoryService _chatHistoryService = ChatHistoryService();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isWaitingForResponse = false;
  bool _isLoadingConversation = false;
  String? _loadError;

  String? _sessionId;
  late String _chatTitle;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.initialSessionId;
    _chatTitle = widget.initialTitle.trim().isEmpty
        ? 'New Chat'
        : widget.initialTitle.trim();
    _messageController.addListener(_handleTypingState);

    if (_sessionId != null && _sessionId!.isNotEmpty) {
      _loadExistingConversation();
    } else {
      _initializeNewConversation();
    }
  }

  void _initializeNewConversation() {
    final initialMessage = widget.initialUserMessage?.trim() ?? '';
    if (initialMessage.isEmpty) return;

    _messages.add(_ChatMessage(text: initialMessage, isUser: true));
    _sendInitialMessage(initialMessage);
  }

  void _handleTypingState() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTypingState);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  LiquidGlassSettings get _darkGlass => LiquidGlassSettings(
    blur: 4,
    glassColor: const Color.fromARGB(255, 69, 69, 69).withValues(alpha: 0.18),
  );

  bool get _canSendMessage =>
      _isTyping && !_isWaitingForResponse && !_isLoadingConversation;

  Future<void> _loadExistingConversation() async {
    final sessionId = _sessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    setState(() {
      _isLoadingConversation = true;
      _loadError = null;
    });

    try {
      final turns = await _chatHistoryService.fetchSessionTurns(sessionId);
      final loadedMessages = <_ChatMessage>[];

      for (final turn in turns) {
        if (turn.userMessage.trim().isNotEmpty) {
          loadedMessages.add(
            _ChatMessage(text: turn.userMessage, isUser: true),
          );
        }
        if (turn.botMessage.trim().isNotEmpty) {
          loadedMessages.add(
            _ChatMessage(text: turn.botMessage, isUser: false),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(loadedMessages);
        _isLoadingConversation = false;
      });
      _scheduleScrollToBottom(animated: false);
    } catch (e, stack) {
      debugPrint('History load error: $e');
      debugPrint('$stack');
      if (!mounted) return;
      setState(() {
        _isLoadingConversation = false;
        _loadError = 'خطا در بارگذاری تاریخچه مکالمه.';
      });
    }
  }

  Future<void> _sendInitialMessage(String initialMessage) async {
    setState(() {
      _isWaitingForResponse = true;
    });
    _scheduleScrollToBottom();

    try {
      final response = await _chatbotService.sendUserMessage(initialMessage);
      _applyResponse(response);
    } catch (e, stack) {
      debugPrint('Chatbot error: $e');
      debugPrint('$stack');
      _applyError();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isWaitingForResponse || _isLoadingConversation) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isTyping = false;
      _isWaitingForResponse = true;
      _loadError = null;
    });
    _scheduleScrollToBottom();

    try {
      final response = await _chatbotService.sendUserMessage(
        text,
        sessionId: _sessionId,
      );
      _applyResponse(response);
    } catch (e, stack) {
      debugPrint('Chatbot error: $e');
      debugPrint('$stack');
      _applyError();
    }
  }

  void _applyResponse(ChatbotResponse response) {
    if (!mounted) return;
    setState(() {
      _sessionId = response.sessionId;
      if (response.title.isNotEmpty) {
        _chatTitle = response.title;
      }
      _messages.add(_ChatMessage(text: response.message, isUser: false));
      _isWaitingForResponse = false;
    });
    _scheduleScrollToBottom();
  }

  void _applyError() {
    if (!mounted) return;
    setState(() {
      _messages.add(
        const _ChatMessage(
          text: 'خطا در دریافت پاسخ. لطفاً دوباره تلاش کنید.',
          isUser: false,
        ),
      );
      _isWaitingForResponse = false;
    });
    _scheduleScrollToBottom();
  }

  void _scheduleScrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _openHistoryPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
  }

  void _showCopiedSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'copy Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'nova',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 38, 38, 38),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showCopiedSnackBar();
  }

  Future<void> _copyLastBotMessage() async {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser && _messages[i].text.trim().isNotEmpty) {
        await _copyToClipboard(_messages[i].text);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GlassButton(
                    width: 52,
                    height: 52,
                    onTap: _openHistoryPage,
                    settings: _darkGlass,
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    icon: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _chatTitle,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 20,
                        fontFamily: 'nova-bold',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  GlassButton(
                    width: 52,
                    height: 52,
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    settings: _darkGlass,
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 18),
                  if (_isLoadingConversation)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 14,
                        ),
                      ),
                    ),
                  if (_loadError != null && !_isLoadingConversation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _InlineNotice(
                        text: _loadError!,
                        onTap: _loadExistingConversation,
                      ),
                    ),
                  ..._messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ChatBubble(message: message),
                    ),
                  ),
                  if (_isWaitingForResponse)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: _TypingIndicator(),
                    ),
                  if (_messages.isEmpty &&
                      !_isLoadingConversation &&
                      _loadError == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: _EmptyChatState(),
                    ),
                  if (_messages.isNotEmpty &&
                      !_isWaitingForResponse &&
                      !_isLoadingConversation) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.hand_thumbsup,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 22,
                        ),
                        const SizedBox(width: 18),
                        Icon(
                          CupertinoIcons.hand_thumbsdown,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 22,
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _copyLastBotMessage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.content_copy_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 130),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: keyboardBottom > 0 ? keyboardBottom + 16 : 24,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: GlassTextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 1,
                        settings: LiquidGlassSettings(
                          glassColor: const Color.fromARGB(
                            255,
                            27,
                            27,
                            27,
                          ).withValues(alpha: 0.6),
                          blur: 10,
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.add,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 22,
                        ),
                        suffixIcon: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _canSendMessage ? _sendMessage : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: const Color.fromARGB(
                                255,
                                24,
                                38,
                                98,
                              ).withValues(alpha: _canSendMessage ? 1 : 0.5),
                            ),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 24,
                            ),
                          ),
                        ),
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: 'Ask Cura AI',
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 99,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Color.fromARGB(167, 255, 255, 255),
                          fontSize: 19,
                          fontFamily: 'nova',
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'nova',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  bool _showCopyButton = false;

  void _toggleCopyButton() {
    setState(() {
      _showCopyButton = !_showCopyButton;
    });
  }

  void _showCopiedSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'copy Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'nova',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 38, 38, 38),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    final text = widget.message.text;
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showCopiedSnackBar();
  }

  MarkdownStyleSheet get _markdownStyle => MarkdownStyleSheet(
    p: TextStyle(
      color: Colors.white.withValues(alpha: 0.86),
      fontSize: 18,
      height: 1.5,
      fontFamily: 'nova',
    ),
    pPadding: const EdgeInsets.symmetric(vertical: 4),
    h1: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      fontSize: 24,
      fontFamily: 'nova-black',
      fontWeight: FontWeight.w800,
      height: 1.3,
    ),
    h2: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      fontSize: 22,
      fontFamily: 'nova-black',
      fontWeight: FontWeight.w800,
      height: 1.3,
    ),
    h3: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      fontSize: 19,
      fontFamily: 'nova-black',
      fontWeight: FontWeight.w800,
      height: 1.3,
    ),
    h4: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      fontSize: 17,
      fontFamily: 'nova-bold',
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    h5: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      fontSize: 16,
      fontFamily: 'nova-bold',
      fontWeight: FontWeight.w700,
    ),
    h6: TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      fontSize: 15,
      fontFamily: 'nova-bold',
      fontWeight: FontWeight.w700,
    ),
    strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    em: TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      fontStyle: FontStyle.italic,
    ),
    del: const TextStyle(
      color: Colors.white54,
      decoration: TextDecoration.lineThrough,
    ),
    listBullet: TextStyle(
      color: Colors.white.withValues(alpha: 0.86),
      fontSize: 16,
    ),
    listIndent: 22,
    code: TextStyle(
      color: Colors.white.withValues(alpha: 0.95),
      backgroundColor: const Color.fromARGB(255, 45, 45, 45),
      fontFamily: 'monospace',
      fontSize: 14,
    ),
    codeblockPadding: const EdgeInsets.all(14),
    codeblockDecoration: BoxDecoration(
      color: const Color.fromARGB(255, 30, 30, 30),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    blockquoteDecoration: BoxDecoration(
      color: const Color.fromARGB(255, 35, 35, 35),
      borderRadius: BorderRadius.circular(10),
      border: Border(
        left: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 3),
      ),
    ),
    a: const TextStyle(
      color: Color.fromARGB(255, 130, 170, 255),
      decoration: TextDecoration.underline,
    ),
    horizontalRuleDecoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
    ),
    tableHead: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    tableBody: TextStyle(color: Colors.white.withValues(alpha: 0.86)),
    tableBorder: TableBorder.all(
      color: Colors.white.withValues(alpha: 0.1),
      width: 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleCopyButton,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 28, 28, 28),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  widget.message.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.94),
                    height: 1.45,
                    fontSize: 18,
                    fontFamily: 'nova',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _showCopyButton
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, right: 2),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _copyToClipboard,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 45, 45, 45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.content_copy_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return MarkdownBody(
      data: widget.message.text,
      selectable: true,
      styleSheet: _markdownStyle,
      onTapLink: (text, href, title) {
        if (href == null || href.isEmpty) return;
        Clipboard.setData(ClipboardData(text: href));
        _showCopiedSnackBar();
      },
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          CupertinoIcons.chat_bubble_2,
          color: Colors.white.withValues(alpha: 0.7),
          size: 40,
        ),
        const SizedBox(height: 14),
        Text(
          'No messages in this conversation yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 16,
            fontFamily: 'nova',
          ),
        ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text, required this.onTap});

  final String text;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                fontFamily: 'nova',
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'nova-black',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = (_controller.value - (index * 0.2)) % 1.0;
                final wave = t < 0.5 ? t * 2 : (1 - t) * 2;
                final scale = 1.0 + (wave * 0.6);
                final opacity = 0.35 + (wave * 0.65);
                return Opacity(
                  opacity: opacity.clamp(0.35, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
