import 'package:cura/core/theme/app_theme.dart';
import 'package:cura/navigation/bottom_nav_bar.dart';
import 'package:cura/screen/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late List<AnimationController> _dotControllers;
  final List<Animation<double>> _dotAnimations = [];

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _textController.forward();

    _dotControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    for (int i = 0; i < 3; i++) {
      _dotAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _dotControllers[i],
            curve: Curves.easeInOutSine,
          ),
        ),
      );

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _dotControllers[i].repeat(reverse: true);
        }
      });
    }

    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (!mounted) return;

      if (session != null) {
        debugPrint("User is already logged in. Redirecting to HomePage...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavBar(1)),
        );
      } else {
        debugPrint("No active session found. Redirecting to LoginPage...");
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      debugPrint("Failed to check auth status: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خطا در برقراری ارتباط با سرور! لطفا اتصال اینترنت را بررسی کنید.',
              style: TextStyle(fontFamily: "nova"),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom + 32;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBar,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F10),
        body: Stack(
          children: [
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const Text(
                  'Cura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: "nova-black",
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: bottomPadding,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _dotAnimations[index],
                    builder: (context, child) {
                      final value = _dotAnimations[index].value;
                      final double jumpY = value * -30;

                      double width = 10.0;
                      double height = 10.0;

                      if (value > 0.8) {
                        width = 8.5;
                        height = 13.0;
                      } else if (value < 0.15) {
                        width = 14.0;
                        height = 7.0;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        transform: Matrix4.translationValues(0, jumpY, 0),
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.white38,
                            Colors.white,
                            value,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: value < 0.2
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
