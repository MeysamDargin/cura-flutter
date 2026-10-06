import 'package:cura/core/format/profile_name.dart';
import 'package:cura/widget/home_gradient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompassPage extends StatefulWidget {
  final double bottomBarTopOffset;

  const CompassPage({super.key, this.bottomBarTopOffset = 90.0});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<String> _userNameFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Map<String, dynamic>> _compassCategories = [
    {
      "title": "Healing\nMusic",
      "icon": CupertinoIcons.music_note_2,
      "color": Colors.red,
    },
    {
      "title": "Guided\nMeditation",
      "icon": CupertinoIcons.wind,
      "color": Colors.green,
    },
    {
      "title": "CBT\nExercises",
      "icon": CupertinoIcons.heart_circle_fill,
      "color": Colors.blueAccent,
    },
    {
      "title": "Mindful\nJournals",
      "icon": CupertinoIcons.book_solid,
      "color": Colors.yellow,
    },
  ];

  @override
  void initState() {
    super.initState();
    _userNameFuture = _getUserName();
    _searchController.addListener(_handleSearchTextChange);
  }

  void _handleSearchTextChange() {
    final hasText = _searchController.text.trim().isNotEmpty;
    if (hasText != _isSearching) {
      setState(() {
        _isSearching = hasText;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchTextChange);
    _searchController.dispose();
    super.dispose();
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
    final bool hideSloganContent = _isSearching || isKeyboardVisible;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: SubtleHomeGradient()),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Compass",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 28,
                          fontFamily: "nova-black",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      GlassButton(
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
                          CupertinoIcons.square_list,
                          color: Colors.white,
                          size: 24,
                        ),
                        onTap: () {
                          debugPrint("Review button pressed");
                        },
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!hideSloganContent) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
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
                                  fontSize: 32,
                                  fontFamily: "nova-black",
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Take a breath, \n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  TextSpan(
                                    text: name,
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
                              "Discover spaces curated for your mental well-being.",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontFamily: "nova",
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          minLines: 1,
                          maxLines: 1,
                          settings: LiquidGlassSettings(
                            blur: 4,
                            glassColor: const Color.fromARGB(
                              255,
                              69,
                              69,
                              69,
                            ).withValues(alpha: 0.2),
                          ),
                          controller: _searchController,
                          quality: GlassQuality.premium,
                          useOwnLayer: true,
                          placeholder: "Search music, meditation, exercises...",
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 25,
                          ),
                          placeholderStyle: const TextStyle(
                            color: Color.fromARGB(167, 255, 255, 255),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            fontFamily: "nova",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassButton(
                        settings: LiquidGlassSettings(
                          glassColor: _isSearching
                              ? Colors.blueAccent.withValues(alpha: 0.5)
                              : const Color.fromARGB(
                                  255,
                                  69,
                                  69,
                                  69,
                                ).withValues(alpha: 0.2),
                        ),
                        width: 50,
                        height: 50,
                        icon: const Icon(
                          CupertinoIcons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                        onTap: () {
                          final query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            debugPrint("Searching for: $query");
                          }
                        },
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
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
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _compassCategories.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.0,
                                ),
                            itemBuilder: (context, index) {
                              final category = _compassCategories[index];
                              return GlassButton(
                                onTap: () {
                                  debugPrint(
                                    "Navigating to ${category['title']}",
                                  );
                                },
                                settings: LiquidGlassSettings(
                                  glassColor: category['color']?.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                quality: GlassQuality.premium,
                                useOwnLayer: true,
                                shape: const LiquidRoundedRectangle(
                                  borderRadius: 28,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                icon: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          category['icon'] as IconData,
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          size: 40,
                                        ),
                                      ),

                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Text(
                                          category['title'] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "nova-black",
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: isKeyboardVisible
                              ? MediaQuery.of(context).viewInsets.bottom + 20.0
                              : widget.bottomBarTopOffset + 40.0,
                        ),
                      ],
                    ),
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
