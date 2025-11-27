// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Card Master Theme - Premium casino aesthetic with golden accents
///
/// Based on wireframe designs with dark navy backgrounds,
/// golden/yellow gradient buttons, and teal/green accents.
class Palette {
  // Background Colors - Rich dark navy with subtle gradients
  Color get backgroundMain => const Color(0xFF0A1628); // Deep navy
  Color get backgroundSecondary => const Color(0xFF142038); // Lighter navy
  Color get backgroundElevated => const Color(0xFF1A2942); // Card surfaces
  Color get backgroundCard => const Color(0xFF1F3152); // Game cards
  Color get backgroundOverlay => const Color(0xE6000000); // 90% black overlay

  // Legacy support
  Color get backgroundPlayArea => const Color(0xFF0A1628);
  Color get backgroundPlaySession => const Color(0xFF0A1628);
  Color get backgroundLevelSelection => const Color(0xFF0A1628);
  Color get backgroundSettings => const Color(0xFF142038);

  // Primary Colors - Golden/Yellow gradient for premium feel
  Color get goldLight => const Color(0xFFF2C94C); // Light gold
  Color get goldMedium => const Color(0xFFE8B339); // Medium gold
  Color get goldDark => const Color(0xFFD4A028); // Dark gold
  Color get gold => const Color(0xFFE8B339); // Default gold

  // Legacy support
  Color get pen => const Color(0xFFE8B339);
  Color get darkPen => const Color(0xFFD4A028);

  // Secondary Colors - Teal/Green accents
  Color get tealLight => const Color(0xFF1DD3B0); // Bright teal
  Color get tealMedium => const Color(0xFF14B89B); // Medium teal
  Color get tealDark => const Color(0xFF0F9E86); // Dark teal
  Color get greenSuccess => const Color(0xFF27AE60); // Success green
  Color get greenBuyCoins => const Color(0xFF27AE60); // "Buy Coins" button

  // UI State Colors
  Color get success => const Color(0xFF27AE60); // Green for success/join
  Color get error => const Color(0xFFEB5757); // Red for errors
  Color get warning => const Color(0xFFF2994A); // Orange for warnings
  Color get disabled => const Color(0xFF4A5568); // Gray for disabled states
  Color get disabledText => const Color(0xFF718096); // Text on disabled

  // Legacy support
  Color get redPen => const Color(0xFFEB5757);
  Color get accept => const Color(0xFF27AE60);
  Color get cyan => const Color(0xFF1DD3B0);

  // Text Colors
  Color get textPrimary => const Color(0xFFFFFFFF); // Pure white
  Color get textSecondary => const Color(0xFFE2E8F0); // Light gray
  Color get textTertiary => const Color(0xFFA0AEC0); // Medium gray
  Color get textDisabled => const Color(0xFF718096); // Dark gray
  Color get textOnGold => const Color(0xFF1A202C); // Dark text on gold buttons

  // Legacy support
  Color get ink => const Color(0xFFFFFFFF);
  Color get inkFullOpacity => const Color(0xFFFFFFFF);

  // Border Colors
  Color get borderGold => const Color(0xFFE8B339); // Golden borders
  Color get borderLight => const Color(0xFF2D3748); // Subtle borders
  Color get borderMedium => const Color(0xFF4A5568); // Medium borders

  // Utility
  Color get trueWhite => const Color(0xFFFFFFFF);
  Color get pureBlack => const Color(0xFF000000);
  Color get surfaceOverlay => const Color(0x1AFFFFFF); // 10% white overlay
  Color get dialogOverlay => const Color(0xCC000000); // 80% black for dialogs
  Color get cardShadowColor => const Color(0x40000000); // 25% black shadow

  // Typography
  String get titleFontFamily => 'Permanent Marker'; // For "CARD MASTER" logo
  String get headingFontFamily => 'Roboto'; // For headings
  String get bodyFontFamily => 'Roboto'; // For body text

  // Gradients
  LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1628), // Deep navy top
          Color(0xFF142038), // Medium navy
          Color(0xFF1F5156), // Teal-tinged bottom
        ],
        stops: [0.0, 0.5, 1.0],
      );

  LinearGradient get goldGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF2C94C), // Light gold
          Color(0xFFE8B339), // Medium gold
          Color(0xFFD4A028), // Dark gold
        ],
        stops: [0.0, 0.5, 1.0],
      );

  LinearGradient get tealGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1DD3B0), // Light teal
          Color(0xFF14B89B), // Medium teal
        ],
      );

  // Shadows
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x40000000),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: const Color(0x40000000),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: const Color(0x80E8B339), // Golden glow
          blurRadius: 16,
          offset: const Offset(0, 0),
        ),
      ];
}
