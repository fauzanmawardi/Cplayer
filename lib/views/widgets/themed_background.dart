// lib/views/widgets/themed_background.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/background_controller.dart';
import '../../utils/app_colors.dart';

/// View: background global aplikasi, dipasang sekali lewat MaterialApp.builder.
class ThemedBackground extends ConsumerWidget {
  final Widget child;
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = ref.watch(backgroundControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        image: bg.hasCustomBackground
            ? DecorationImage(
                image: FileImage(File(bg.imagePath!)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.background.withOpacity(0.7),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}