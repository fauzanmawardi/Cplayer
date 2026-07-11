import 'package:flutter/material.dart';

import '../../../shell/presentation/screens/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHome();
  }

  Future<void> _goToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

 @override
  Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return SizedBox.expand(
  child: FittedBox(
    fit: BoxFit.contain,
    child: Image.asset(
      'assets/splash_logo.png',
    ),
  ),
  );
}
}