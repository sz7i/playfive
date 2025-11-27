// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_screen.dart';
import 'game_internals/score.dart';
import 'main_menu/main_menu_screen.dart';
import 'multiplayer/screens/lobby_screen.dart';
import 'multiplayer/screens/room_screen.dart';
import 'play_session/play_session_screen.dart';
import 'settings/settings_screen.dart';
import 'style/my_transition.dart';
import 'style/palette.dart';
import 'ui/demo_screen.dart';
import 'win_game/win_game_screen.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens all the way to each individual level.
final router = GoRouter(
  redirect: (context, state) {
    final authController = context.read<AuthController>();

    // Don't redirect while still loading auth state
    if (authController.isLoading) {
      return null;
    }

    final isAuthenticated = authController.isAuthenticated;
    final isAuthRoute = state.matchedLocation == '/auth';

    // Redirect to auth if not authenticated and not already on auth screen
    if (!isAuthenticated && !isAuthRoute) {
      return '/auth';
    }

    // Redirect to home if authenticated and on auth screen
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(key: Key('auth')),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const LobbyScreen(key: Key('lobby')),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              const SettingsScreen(key: Key('settings')),
        ),
        GoRoute(
          path: 'ui-demo',
          builder: (context, state) =>
              const UIKitDemoScreen(key: Key('ui-demo')),
        ),
      ],
    ),
    GoRoute(
      path: '/room/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return RoomScreen(roomId: roomId, key: Key('room-$roomId'));
      },
    ),
    // Keep old single-player routes for reference
    GoRoute(
      path: '/single-player',
      builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
      routes: [
        GoRoute(
          path: 'play',
          pageBuilder: (context, state) => buildMyTransition<void>(
            key: const ValueKey('play'),
            color: context.watch<Palette>().backgroundPlaySession,
            child: const PlaySessionScreen(key: Key('level selection')),
          ),
          routes: [
            GoRoute(
              path: 'won',
              redirect: (context, state) {
                if (state.extra == null) {
                  // Trying to navigate to a win screen without any data.
                  // Possibly by using the browser's back button.
                  return '/';
                }

                // Otherwise, do not redirect.
                return null;
              },
              pageBuilder: (context, state) {
                final map = state.extra! as Map<String, dynamic>;
                final score = map['score'] as Score;

                return buildMyTransition<void>(
                  key: const ValueKey('won'),
                  color: context.watch<Palette>().backgroundPlaySession,
                  child: WinGameScreen(
                    score: score,
                    key: const Key('win game'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
