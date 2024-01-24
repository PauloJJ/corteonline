import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/services/admob_service.dart';
import 'package:nico/services/auth_service.dart';
import 'package:nico/services/schedules_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();

  await FirebaseAnalytics.instance.logEvent(
    name: 'init_app',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (context) => SchedulesService(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdMobService(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color.fromARGB(255, 31, 31, 31),
            onPrimary: Color(0xFFFFFFFF),
            primaryContainer: Color(0xFFD8E2FF),
            onPrimaryContainer: Color(0xFF001A42),
            secondary: Color(0xFF006874),
            onSecondary: Color(0xFFFFFFFF),
            secondaryContainer: Color(0xFF97F0FF),
            onSecondaryContainer: Color(0xFF001F24),
            tertiary: Color(0xFF4459A9),
            onTertiary: Color(0xFFFFFFFF),
            tertiaryContainer: Color(0xFFDDE1FF),
            onTertiaryContainer: Color(0xFF001453),
            error: Color(0xFFBA1A1A),
            errorContainer: Color(0xFFFFDAD6),
            onError: Color(0xFFFFFFFF),
            onErrorContainer: Color(0xFF410002),
            background: Color(0xFFFEFBFF),
            onBackground: Color(0xFF1B1B1F),
            surface: Color(0xFFFEFBFF),
            onSurface: Color(0xFF1B1B1F),
            surfaceVariant: Color(0xFFE1E2EC),
            onSurfaceVariant: Color(0xFF44474F),
            outline: Color(0xFF75777F),
            onInverseSurface: Color(0xFFF2F0F4),
            inverseSurface: Color(0xFF303034),
            inversePrimary: Color(0xFFADC6FF),
            shadow: Color(0xFF000000),
            surfaceTint: Color(0xFF315DA8),
            outlineVariant: Color(0xFFC4C6D0),
            scrim: Color(0xFF000000),
          ),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.montserrat(),
            bodyMedium: GoogleFonts.montserrat(
              fontSize: 17,
            ),
            bodySmall: GoogleFonts.montserrat(
              fontSize: 25,
            ),
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.montserrat(
              fontSize: 22,
            ),
          ),
        ),
        home: AuthOrAppComponent(
          index: 0,
        ),
      ),
    );
  }
}
