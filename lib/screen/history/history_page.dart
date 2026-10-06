import 'package:cura/core/format/chat_timestamp.dart';
import 'package:cura/screen/chat/chat_page.dart';
import 'package:cura/services/chat_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ChatHistoryService _historyService = ChatHistoryService();
  late Future<List<ChatSessionSummary>> _sessionsFuture;
  final Set<String> _busySessionIds = <String>{};

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _historyService.fetchChatSessions();
  }

  Future<void> _refreshSessions() async {
    final future = _historyService.fetchChatSessions();
    setState(() {
      _sessionsFuture = future;
    });
    await future;
  }

  void _openSession(ChatSessionSummary session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          initialSessionId: session.sessionId,
          initialTitle: session.title,
        ),
      ),
    );
  }

  Future<void> _showSessionActions(ChatSessionSummary session) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color.fromARGB(255, 16, 16, 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'nova-black',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage this conversation',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 13,
                    fontFamily: 'nova',
                  ),
                ),
                const SizedBox(height: 18),
                _ActionTile(
                  icon: CupertinoIcons.delete,
                  title: 'Delete chat',
                  subtitle: 'Remove this conversation and all its messages',
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDeleteSession(session);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSession(ChatSessionSummary session) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 22, 22, 22),
          title: const Text(
            'Delete this chat?',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'nova-black',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This conversation and all saved messages inside it will be removed.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontFamily: 'nova',
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'nova-black',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'nova-black',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    await _runSessionAction(
      sessionId: session.sessionId,
      action: () => _historyService.deleteSession(session.sessionId),
      errorMessage: 'حذف مکالمه انجام نشد.',
    );
  }

  Future<void> _runSessionAction({
    required String sessionId,
    required Future<void> Function() action,
    required String errorMessage,
  }) async {
    setState(() {
      _busySessionIds.add(sessionId);
    });

    try {
      await action();
      await _refreshSessions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _busySessionIds.remove(sessionId);
        });
      }
    }
  }

  LiquidGlassSettings get _glassSettings => LiquidGlassSettings(
    blur: 4,
    glassColor: const Color.fromARGB(255, 69, 69, 69).withValues(alpha: 0.18),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    onTap: () => Navigator.of(context).maybePop(),
                    settings: _glassSettings,
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat History',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.96),
                            fontSize: 22,
                            fontFamily: 'nova-black',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Your recent Cura conversations',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontFamily: 'nova',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassButton(
                    width: 52,
                    height: 52,
                    onTap: _refreshSessions,
                    settings: _glassSettings,
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    icon: const Icon(
                      CupertinoIcons.refresh,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<ChatSessionSummary>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 14,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _HistoryMessageState(
                      icon: Icons.error_outline,
                      title: 'Could not load conversations',
                      subtitle: 'Pull to refresh or try again in a moment.',
                      actionLabel: 'Retry',
                      onTap: _refreshSessions,
                    );
                  }

                  final sessions =
                      snapshot.data ?? const <ChatSessionSummary>[];
                  if (sessions.isEmpty) {
                    return _HistoryMessageState(
                      icon: Icons.history_toggle_off,
                      title: 'No conversations yet',
                      subtitle: 'Start a new chat and it will appear here.',
                      actionLabel: 'Refresh',
                      onTap: _refreshSessions,
                    );
                  }

                  return RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    onRefresh: _refreshSessions,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
                      itemCount: sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _HistorySessionCard(
                          session: session,
                          onTap: () => _openSession(session),
                          onMoreTap: () => _showSessionActions(session),
                          isBusy: _busySessionIds.contains(session.sessionId),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({
    required this.session,
    required this.onTap,
    required this.onMoreTap,
    required this.isBusy,
  });

  final ChatSessionSummary session;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: const Color.fromARGB(255, 21, 21, 21),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  33,
                  52,
                  127,
                ).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'nova-black',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(session.lastActivity),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.48),
                          fontSize: 12,
                          fontFamily: 'nova',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 14,
                      fontFamily: 'nova',
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isBusy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 9,
                ),
              )
            else
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onMoreTap,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white.withValues(alpha: 0.62),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime? dateTime) {
    return formatChatTimestamp(dateTime);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDestructive
        ? Colors.redAccent
        : Colors.white.withValues(alpha: 0.92);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 29, 29, 29),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: foregroundColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: foregroundColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 15,
                      fontFamily: 'nova-black',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 13,
                      fontFamily: 'nova',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.34),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMessageState extends StatelessWidget {
  const _HistoryMessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 44),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'nova-black',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.56),
                fontSize: 14,
                fontFamily: 'nova',
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: onTap,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'nova-black',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
