import 'package:cura/screen/compass/compass_page.dart';
import 'package:cura/screen/home/home_page.dart';
import 'package:cura/screen/oracle/oracle_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vibration/vibration.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(this.initialIndex, {super.key});

  final int initialIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  late int _currentIndex;
  final GlobalKey _bottomBarKey = GlobalKey();
  double _bottomBarTopOffset = 90;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureBottomBar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureBottomBar());
  }

  void _measureBottomBar() {
    if (!mounted) return;
    final barContext = _bottomBarKey.currentContext;
    if (barContext == null) return;

    final renderBox = barContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final newOffset = screenHeight - position.dy;

    if ((newOffset - _bottomBarTopOffset).abs() > 0.5) {
      setState(() => _bottomBarTopOffset = newOffset);
    }
  }

  Future<void> _onTabTapped(int index) async {
    if (_currentIndex != index) {
      _triggerHapticFeedback();
    }
    setState(() => _currentIndex = index);
  }

  void _triggerHapticFeedback() {
    Future(() async {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 33);
        }
      } catch (error) {
        debugPrint('Vibration not available: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final systemBottom = isApple
        ? 0.0
        : MediaQuery.viewPaddingOf(context).bottom;

    final pages = [
      CompassPage(bottomBarTopOffset: _bottomBarTopOffset),
      HomePage(bottomBarTopOffset: _bottomBarTopOffset),
      const OraclePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),
          Positioned(
            left: 45,
            right: 45,
            bottom: systemBottom,
            child: KeyedSubtree(
              key: _bottomBarKey,
              child: GlassTabBar.bottom(
                selectedIndex: _currentIndex,
                onTabSelected: _onTabTapped,
                selectedIconColor: const Color(0xff0575DF),
                unselectedIconColor: const Color.fromARGB(255, 188, 188, 188),
                labelFontSize: 11,
                iconSize: 28,
                iconLabelSpacing: 0,
                indicatorColor: const Color.fromARGB(
                  53,
                  87,
                  119,
                  143,
                ).withValues(alpha: 0.3),
                quality: GlassQuality.premium,
                interactionBehavior: GlassInteractionBehavior.full,
                settings: LiquidGlassSettings(
                  glassColor: const Color.fromARGB(0, 0, 0, 0),
                  thickness: 30,
                  blur: 3,
                  chromaticAberration: .01,
                  lightAngle: GlassDefaults.lightAngle,
                  lightIntensity: .5,
                  ambientStrength: 0,
                  refractiveIndex: 1.3,
                  saturation: 1.2,
                  specularSharpness: GlassSpecularSharpness.medium,
                ),
                tabs: const [
                  GlassTab(
                    label: 'compass',
                    icon: Icon(CupertinoIcons.compass, size: 30),
                    activeIcon: Icon(CupertinoIcons.compass_fill, size: 30),
                  ),
                  GlassTab(
                    label: 'Chats',
                    icon: Icon(CupertinoIcons.chat_bubble_2_fill, size: 33),
                    activeIcon: Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 33,
                    ),
                  ),
                  GlassTab(
                    label: 'Oracle',
                    icon: Icon(Icons.auto_awesome, size: 27),
                    activeIcon: Icon(Icons.auto_awesome, size: 27),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void openHomeShell(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const BottomNavBar(1)),
    (route) => false,
  );
}
