import 'package:cura/core/format/profile_name.dart';
import 'package:cura/widget/home_gradient.dart';
import 'package:cura/screen/chat/chat_page.dart';
import 'package:cura/screen/history/history_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final double bottomBarTopOffset;

  const HomePage({super.key, this.bottomBarTopOffset = 90.0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<String> _userInitialFuture;
  late Future<String> _userNameFuture;

  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  final List<Map<String, String>> _suggestedPrompts = [
    {
      "title": "Settings Screen UI",
      "desc":
          "Building a Settings screen? Use GlassScaffold + GlassAppBar for navigation chrome, and CupertinoListTile or standard Flutter containers for the rows. Use GlassGroupedSection when you want glass-styled grouped rows.",
    },
    {
      "title": "Database Architecture",
      "desc":
          "How to design a scalable real-time chat schema in Supabase with row-level security (RLS) and optimized indexes for fast querying?",
    },
    {
      "title": "DevOps & Docker",
      "desc":
          "Create a multi-stage Dockerfile for a production-ready web application behind an Nginx reverse proxy with SSL configuration.",
    },
    {
      "title": "AI Agent Logic",
      "desc":
          "Explain how to implement a persistent memory layer for autonomous AI agents using a graph database approach.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _userInitialFuture = _getUserInitial();
    _userNameFuture = _getUserName();
    _messageController.addListener(_handleMessageTextChange);
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/video/welcome.mp4');
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void _handleMessageTextChange() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  void _openChatPage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ChatPage(initialUserMessage: text);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _openHistoryPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleMessageTextChange);
    _messageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<String> _getUserInitial() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return defaultProfileInitial;

      final data = await _supabase
          .from('profiles')
          .select('fullname')
          .eq('user_id', currentUser.id)
          .single();

      return displayInitial(data['fullname'] as String?);
    } catch (e) {
      debugPrint("Error fetching profile initial: $e");
    }
    return defaultProfileInitial;
  }

  Future<String> _getUserName() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return defaultProfileName;

      final data = await _supabase
          .from('profiles')
          .select('fullname')
          .eq('user_id', currentUser.id)
          .single();

      return displayFirstName(data['fullname'] as String?);
    } catch (e) {
      debugPrint("Error fetching profile name: $e");
    }
    return defaultProfileName;
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final bool hideWelcomeContent = _isTyping || isKeyboardVisible;

    return Scaffold(
      backgroundColor: Colors.black,

      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: SubtleHomeGradient()),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassButton(
                        settings: LiquidGlassSettings(
                          glassColor: const Color.fromARGB(
                            141,
                            214,
                            214,
                            214,
                          ).withValues(alpha: 0.12),
                        ),
                        width: 54,
                        height: 54,
                        icon: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 26,
                        ),
                        onTap: _openHistoryPage,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                      ),
                      Text(
                        "Cura",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 26,
                          fontFamily: "nova-black",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<String>(
                        future: _userInitialFuture,
                        builder: (context, snapshot) {
                          final String displayLetter = snapshot.data ?? "...";
                          return GlassPullDownButton(
                            items: [
                              GlassMenuItem(
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                title: 'My account',
                                onTap: () {},
                              ),
                              GlassMenuItem(
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                title: 'Delete',
                                onTap: () {},
                              ),
                            ],
                            buttonWidth: 54,
                            buttonHeight: 54,
                            icon:
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                      radius: 9,
                                    ),
                                  )
                                : Text(
                                    displayLetter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: "nova-black",
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            quality: GlassQuality.premium,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!hideWelcomeContent) ...[
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _isVideoInitialized
                                    ? FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width:
                                              _videoController.value.size.width,
                                          height: _videoController
                                              .value
                                              .size
                                              .height,
                                          child: VideoPlayer(_videoController),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        child: const Center(
                                          child: CupertinoActivityIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: FutureBuilder<String>(
                              future: _userNameFuture,
                              builder: (context, snapshot) {
                                final name = snapshot.data ?? "Explorer";
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontFamily: "nova-black",
                                          color: Colors.white,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Hello, ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "$name!",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Color(0xFF8B5CF6),
                                                  blurRadius: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "What shall we create or solve together today?",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 19,
                                        fontFamily: "nova",
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          Builder(
                            builder: (context) {
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final cardWidth = (screenWidth - 52) / 2;

                              return SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  itemCount: _suggestedPrompts.length,
                                  itemBuilder: (context, index) {
                                    final item = _suggestedPrompts[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                      ),
                                      child: GlassButton(
                                        onTap: () {
                                          _messageController.text =
                                              item['desc'] ?? "";
                                        },
                                        settings: LiquidGlassSettings(
                                          glassColor: const Color.fromARGB(
                                            255,
                                            50,
                                            50,
                                            55,
                                          ).withValues(alpha: 0.3),
                                        ),
                                        quality: GlassQuality.premium,
                                        useOwnLayer: true,
                                        shape: const LiquidRoundedRectangle(
                                          borderRadius: 30,
                                        ),
                                        width: cardWidth,
                                        height: 200,
                                        icon: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'] ?? "",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "nova-black",
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: Text(
                                                  item['desc'] ?? "",
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "nova",
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    left: isKeyboardVisible
                        ? MediaQuery.of(context).viewInsets.left + 5.0
                        : 20.0,
                    right: isKeyboardVisible
                        ? MediaQuery.of(context).viewInsets.right + 5.0
                        : 20.0,
                    top: 12.0,

                    bottom: isKeyboardVisible
                        ? MediaQuery.of(context).viewInsets.bottom + 20.0
                        : widget.bottomBarTopOffset + 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          minLines: 1,
                          maxLines: 3,
                          settings: LiquidGlassSettings(
                            blur: 4,
                            glassColor: const Color.fromARGB(
                              255,
                              69,
                              69,
                              69,
                            ).withValues(alpha: 0.2),
                          ),
                          controller: _messageController,
                          quality: GlassQuality.premium,
                          useOwnLayer: true,
                          placeholder: "Ask Cura",
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 25,
                          ),
                          placeholderStyle: const TextStyle(
                            color: Color.fromARGB(167, 255, 255, 255),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.88, end: 1.0)
                                      .animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                        child: _isTyping
                            ? GlassButton(
                                key: const ValueKey("send_button"),
                                settings: LiquidGlassSettings(
                                  glassColor: Colors.blueAccent.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                width: 50,
                                height: 50,
                                icon: const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 27,
                                ),
                                onTap: () {
                                  _openChatPage();
                                },
                                quality: GlassQuality.premium,
                                useOwnLayer: true,
                                shape: const LiquidRoundedSuperellipse(
                                  borderRadius: 50,
                                ),
                              )
                            : GlassButton(
                                key: const ValueKey("mic_button"),
                                settings: LiquidGlassSettings(
                                  glassColor: const Color.fromARGB(
                                    255,
                                    69,
                                    69,
                                    69,
                                  ).withValues(alpha: 0.2),
                                ),
                                width: 50,
                                height: 50,
                                icon: const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onTap: () {
                                  debugPrint("Voice recording triggered");
                                },
                                quality: GlassQuality.premium,
                                useOwnLayer: true,
                                shape: const LiquidRoundedSuperellipse(
                                  borderRadius: 50,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
