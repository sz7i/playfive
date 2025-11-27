// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'auth/auth_controller.dart';
import 'multiplayer/controllers/room_controller.dart';
import 'player_progress/player_progress.dart';
import 'router.dart';
import 'settings/settings.dart';
import 'style/palette.dart';

void main() async {
  // Basic logging setup.
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
    );
  });

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'http://127.0.0.1:54321',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    ),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Put game into full screen mode on mobile devices.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Lock the game to portrait mode on mobile devices.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthController _authController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _router = createRouter(_authController);
  }

  @override
  void dispose() {
    _authController.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        // This is where you add objects that you want to have available
        // throughout your game.
        //
        // Every widget in the game can access these objects by calling
        // `context.watch()` or `context.read()`.
        // See `lib/main_menu/main_menu_screen.dart` for example usage.
        providers: [
          Provider(create: (context) => SettingsController()),
          Provider(create: (context) => Palette()),
          ChangeNotifierProvider.value(value: _authController),
          ChangeNotifierProvider(create: (context) => RoomController()),
          ChangeNotifierProvider(create: (context) => PlayerProgress()),
          // Set up audio.
          ProxyProvider2<
            AppLifecycleStateNotifier,
            SettingsController,
            AudioController
          >(
            create: (context) => AudioController(),
            update: (context, lifecycleNotifier, settings, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
            // Ensures that music starts immediately.
            lazy: false,
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();

            return MaterialApp.router(
              title: 'PlayFive - Multiplayer Card Games',
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.dark(
                  primary: palette.gold,
                  onPrimary: palette.backgroundMain,
                  secondary: palette.cyan,
                  onSecondary: palette.backgroundMain,
                  error: palette.error,
                  onError: palette.trueWhite,
                  surface: palette.backgroundElevated,
                  onSurface: palette.textPrimary,
                  surfaceContainerHighest: palette.backgroundCard,
                ),
                scaffoldBackgroundColor: palette.backgroundMain,
                cardTheme: CardThemeData(
                  color: palette.backgroundCard,
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.gold,
                    foregroundColor: palette.backgroundMain,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: palette.gold,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: palette.backgroundMain,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: palette.backgroundCard),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: palette.backgroundCard),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: palette.gold, width: 2),
                  ),
                  labelStyle: TextStyle(color: palette.textSecondary),
                  hintStyle: TextStyle(color: palette.textDisabled),
                ),
                textTheme: TextTheme(
                  displayLarge: TextStyle(
                    fontFamily: palette.titleFontFamily,
                    color: palette.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  displayMedium: TextStyle(
                    fontFamily: palette.titleFontFamily,
                    color: palette.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  titleLarge: TextStyle(
                    fontFamily: palette.titleFontFamily,
                    color: palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  titleMedium: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  bodyLarge: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                  ),
                  bodyMedium: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                  ),
                  bodySmall: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
