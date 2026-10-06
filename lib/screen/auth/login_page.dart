import 'package:cura/core/validation/auth_input.dart';
import 'package:cura/core/widgets/app_messenger.dart';
import 'package:cura/navigation/bottom_nav_bar.dart';
import 'package:cura/screen/auth/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _fieldHeight = 56;
  static const double _horizontalPadding = 24;
  static const double _fieldSpacing = 16;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final issue = AuthInput.loginIssue(email: email, password: password);
    if (issue != null) {
      showAppMessage(context, issue, Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (!mounted) return;
        showAppMessage(context, "Welcome back!", Colors.green);
        openHomeShell(context);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message, Colors.redAccent);
    } catch (error) {
      if (!mounted) return;
      showAppMessage(
        context,
        "An unexpected error occurred. Please try again.",
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _AdvancedHeaderGradient()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "nova-black",
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Log in to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "nova",
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassTextField(
                        controller: _emailController,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: "Enter your email",
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                        prefixIcon: const Icon(
                          CupertinoIcons.mail,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: _fieldSpacing),
                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassPasswordField(
                        controller: _passwordController,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: "Enter your password",
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: _fieldSpacing * 1.5),
                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassButton(
                        settings: LiquidGlassSettings(
                          thickness: 10,
                          refractiveIndex: 1,
                          glassColor: Colors.blueAccent.withValues(alpha: 0.9),
                        ),
                        icon: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "nova",
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                        onTap: _isLoading ? () {} : _handleLogin,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontFamily: "nova",
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!_isLoading) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontFamily: "nova-black",
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedHeaderGradient extends StatelessWidget {
  const _AdvancedHeaderGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080710),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF511F8D).withValues(alpha: 0.6),
                    const Color(0xFF2A115C).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -100,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E40AF).withValues(alpha: 0.45),
                    const Color(0xFF0F172A).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1E1B4B).withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
