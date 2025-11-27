// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Modern Card Table Theme - A sophisticated dark theme for card games
///
/// Inspired by premium card rooms with a modern, clean aesthetic.
/// Dark backgrounds reduce eye strain during long gaming sessions,
/// while gold accents provide a premium feel.
class Palette {
  // Background Colors - Dark, elegant card table aesthetic
  Color get backgroundMain => const Color(0xFF0D1B2A); // Deep midnight blue
  Color get backgroundElevated => const Color(0xFF1B263B); // Card table felt
  Color get backgroundCard => const Color(0xFF415A77); // Lighter blue-gray
  Color get backgroundPlayArea => const Color(0xFF1B263B); // Same as elevated
  Color get backgroundPlaySession => const Color(0xFF1B263B);
  Color get backgroundLevelSelection => const Color(0xFF1B263B);
  Color get backgroundSettings => const Color(0xFF1B263B);

  // Primary Accent - Warm gold for premium feel
  Color get gold => const Color(0xFFFFB700);
  Color get pen => const Color(0xFFFFB700); // Keep for compatibility
  Color get darkPen => const Color(0xFFCC9200); // Darker gold

  // Secondary Accent - Bright cyan for contrast
  Color get cyan => const Color(0xFF00D9FF);

  // Semantic Colors
  Color get success => const Color(0xFF00C853); // Vibrant green
  Color get error => const Color(0xFFFF1744); // Bright red
  Color get redPen => const Color(0xFFFF1744); // Keep for compatibility
  Color get warning => const Color(0xFFFF9100); // Orange
  Color get accept => const Color(0xFF00C853); // Same as success

  // Text Colors
  Color get textPrimary => const Color(0xFFFFFFFF); // Pure white
  Color get textSecondary => const Color(0xFFB0BEC5); // Light gray
  Color get textDisabled => const Color(0xFF546E7A); // Medium gray
  Color get ink => const Color(0xFFFFFFFF); // White for dark backgrounds
  Color get inkFullOpacity => const Color(0xFFFFFFFF);

  // Utility
  Color get trueWhite => const Color(0xFFFFFFFF);
  Color get surfaceOverlay => const Color(0x1AFFFFFF); // 10% white overlay

  // Typography
  String get titleFontFamily => 'Permanent Marker';
  String get bodyFontFamily => 'Roboto';

  // Gradients
  LinearGradient get cardTableGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B263B),
          const Color(0xFF0D1B2A),
        ],
      );

  LinearGradient get goldGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFB700),
          const Color(0xFFCC9200),
        ],
      );
}
