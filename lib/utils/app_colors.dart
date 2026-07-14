import 'package:flutter/material.dart';

/// Semua warna dipusatkan di sini supaya tampilan tetap konsisten
/// di seluruh aplikasi (Home, Music, Video, Player, Settings, dll).
class AppColors {
  AppColors._();

  // Background & surface
  static const Color background = Color(0xFF0A0A12);
  static const Color surface = Color(0xFF15151F);
  static const Color surfaceLight = Color(0xFF1E1E2A);
  static const Color card = Color(0xFF1A1A26);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Brand gradient (cyan -> blue -> purple -> pink), seperti logo CPlayer
  static const List<Color> brandGradient = [
    Color(0xFF22D3EE),
    Color(0xFF6366F1),
    Color(0xFFD946EF),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: brandGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient musicCardGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient videoCardGradient = LinearGradient(
    colors: [Color(0xFFC026D3), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color accent = Color(0xFF8B5CF6);
  static const Color favorite = Color(0xFFEC4899);
  static const Color divider = Color(0xFF262632);

  // Palet warna cover placeholder untuk lagu / video (dummy data)
  static const List<Color> coverPalette = [
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
  ];
}
