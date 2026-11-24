import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openHome();
  }

  Future<void> _openHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7E9), Color(0xFFF5EDFF), Color(0xFFFFFDFC)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 105,
              right: 42,
              child: Text(
                '✦',
                style: TextStyle(fontSize: 27, color: Color(0xFFE6B45F)),
              ),
            ),
            const Positioned(
              top: 190,
              left: 38,
              child: Text(
                '✧',
                style: TextStyle(fontSize: 34, color: Color(0xFFB49AD8)),
              ),
            ),
            const Positioned(
              bottom: 170,
              right: 55,
              child: Text(
                '✧',
                style: TextStyle(fontSize: 30, color: Color(0xFFE6B45F)),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.82),
                        border: Border.all(
                          color: const Color(0xFFEAD9BC),
                          width: 1.4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1C7255A5),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('☀️', style: TextStyle(fontSize: 58)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Astrology',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find clarity in your stars',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.muted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppTheme.plum,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'A LITTLE GUIDANCE FROM THE UNIVERSE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.7,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
