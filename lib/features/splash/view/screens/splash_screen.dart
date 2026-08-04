import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../generated/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.onFinished,
    super.key,
  });

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _displayDuration = Duration(seconds: 1);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_displayDuration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Material(
        color: AppColors.primary,
        child: _SplashLogo(),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Assets.images.appLogo.image(
        width: MediaQuery.sizeOf(context).width * 0.5,
        fit: BoxFit.contain,
        color: AppColors.white,
        colorBlendMode: BlendMode.srcIn,
        semanticLabel: 'دللني',
      ),
    );
  }
}
