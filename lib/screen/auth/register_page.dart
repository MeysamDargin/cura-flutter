import 'package:cura/core/validation/auth_input.dart';
import 'package:cura/core/widgets/app_messenger.dart';
import 'package:cura/navigation/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const double _fieldHeight = 56;
  static const double _horizontalPadding = 24;
  static const double _fieldSpacing = 14;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final issue = AuthInput.registerIssue(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (issue != null) {
      final isMismatch = issue == AuthInput.passwordMismatchMessage;
      showAppMessage(
        context,
        issue,
        isMismatch ? Colors.redAccent : Colors.orangeAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = response.user;

      if (user != null) {
        await _supabase.from('profiles').insert({
          'user_id': user.id,
          'fullname': fullName,
        });

        if (!mounted) return;
        showAppMessage(context, "Registration successful!", Colors.green);
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
          const Positioned.fill(child: _RegisterHeaderGradient()),

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
                      "Create Account",
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
                      "Sign up to get started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "nova",
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassTextField(
                        controller: _fullNameController,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: "Full Name",
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                        prefixIcon: const Icon(
                          CupertinoIcons.person,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: _fieldSpacing),

                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassTextField(
                        controller: _emailController,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: "Email Address",
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
                        placeholder: "Password",
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 50,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: _fieldSpacing),

                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: GlassPasswordField(
                        controller: _confirmPasswordController,
                        quality: GlassQuality.premium,
                        useOwnLayer: true,
                        placeholder: "Confirm Password",
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
                          glassColor: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.8),
                        ),
                        icon: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "nova",
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                        onTap: _isLoading ? () {} : _handleRegister,
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
                          "Already have an account? ",
                          style: TextStyle(
                            fontFamily: "nova",
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!_isLoading) Navigator.pop(context);
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              fontFamily: "nova-black",
                              color: Color(0xFF10B981),
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

class _RegisterHeaderGradient extends StatelessWidget {
  const _RegisterHeaderGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070B10),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -50,
            width: 450,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha: 0.5),
                    const Color(0xFF065F46).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.4),
                    const Color(0xFF1E1B4B).withValues(alpha: 0.1),
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
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF064E3B).withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.85),
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
