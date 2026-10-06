import 'package:cura/widget/home_gradient.dart';
import 'package:flutter/material.dart';

class OraclePage extends StatelessWidget {
  const OraclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: SubtleHomeGradient()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 42),
                    SizedBox(height: 16),
                    Text(
                      'Oracle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'nova-black',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A quieter space for deeper guidance is on the way.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0x80FFFFFF),
                        fontSize: 16,
                        height: 1.45,
                        fontFamily: 'nova',
                      ),
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
