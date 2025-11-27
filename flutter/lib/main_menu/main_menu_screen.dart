// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../auth/auth_controller.dart';
import '../settings/settings.dart';
import '../ui/ui_kit.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    final authController = context.watch<AuthController>();
    final profile = authController.profile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: palette.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // User Header
              if (profile != null)
                Container(
                  decoration: BoxDecoration(
                    color: palette.backgroundSecondary,
                    border: Border(
                      bottom: BorderSide(
                        color: palette.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => GoRouter.of(context).push('/settings'),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: palette.backgroundCard,
                                backgroundImage: profile.avatarUrl != null &&
                                        profile.avatarUrl!.isNotEmpty
                                    ? NetworkImage(profile.avatarUrl!)
                                    : null,
                                child: profile.avatarUrl == null ||
                                        profile.avatarUrl!.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 28,
                                        color: palette.textTertiary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.username ?? 'Player',
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          size: 14,
                                          color: palette.goldMedium,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '\$12,500',
                                          style: TextStyle(
                                            color: palette.goldMedium,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CMIconButton(
                        icon: Icons.logout,
                        onPressed: () async {
                          final confirmed = await ConfirmDialog.show(
                            context: context,
                            title: 'Logout',
                            message: 'Are you sure you want to logout?',
                            confirmText: 'Logout',
                            cancelText: 'Cancel',
                          );

                          if (confirmed && context.mounted) {
                            await authController.signOut();
                            if (context.mounted) {
                              GoRouter.of(context).go('/auth');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

              // Main content
              Expanded(
                child: ResponsiveScreen(
                  squarishMainArea: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Icon(
                          Icons.style,
                          size: 120,
                          color: palette.goldMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CARD MASTER',
                          style: TextStyle(
                            fontFamily: palette.titleFontFamily,
                            fontSize: 48,
                            color: palette.goldMedium,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag & Drop Cards!',
                          style: TextStyle(
                            fontFamily: palette.titleFontFamily,
                            fontSize: 20,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  rectangularMenuArea: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          text: 'Play',
                          onPressed: () {
                            audioController.playSfx(SfxType.buttonTap);
                            GoRouter.of(context).go('/play');
                          },
                          icon: Icons.play_arrow,
                          width: double.infinity,
                        ),
                        _gap,
                        SecondaryButton(
                          text: 'Settings',
                          onPressed: () => GoRouter.of(context).push('/settings'),
                          icon: Icons.settings,
                          width: double.infinity,
                        ),
                        _gap,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: settingsController.audioOn,
                              builder: (context, audioOn, child) {
                                return CMIconButton(
                                  icon: audioOn ? Icons.volume_up : Icons.volume_off,
                                  onPressed: () => settingsController.toggleAudioOn(),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Music by Mr Smith',
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        _gap,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 12);
}
