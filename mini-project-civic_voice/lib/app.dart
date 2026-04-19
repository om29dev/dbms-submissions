import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/language_provider.dart';
import 'providers/accessibility_provider.dart';

/// Root application widget. Holds the router and theme.
class CVIApp extends StatefulWidget {
  const CVIApp({super.key});

  @override
  State<CVIApp> createState() => _CVIAppState();
}

class _CVIAppState extends State<CVIApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp.router(
      title: 'Civic Voice',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Locale driven by LanguageProvider
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('hi', 'IN'),
        Locale('mr', 'IN'),
        Locale('ta', 'IN'),
      ],

      // Override default font with Rajdhani and add Loading Overlay
      builder: (context, child) {
        final theme = Theme.of(context);
        final access = context.watch<AccessibilityProvider>();

        Widget content = Theme(
          data: theme.copyWith(
            textTheme: GoogleFonts.rajdhaniTextTheme(theme.textTheme),
          ),
          child: child ?? const SizedBox.shrink(),
        );

        if (access.colorFilter != null) {
          content = ColorFiltered(
            colorFilter: access.colorFilter!,
            child: content,
          );
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(access.textScaleFactor),
          ),
          child: content,
        );
      },

      // Router
      routerConfig: _appRouter.router,
    );
  }
}
