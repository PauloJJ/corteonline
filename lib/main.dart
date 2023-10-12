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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF156778),
            onPrimary: Colors.white,
            secondary: Color(0xFFF98601),
            onSecondary: Color(0xFF156778),
            error: Colors.red,
            onError: Colors.white,
            background: Colors.white,
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Color(0xFF156778),
          ),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.montserrat(
                // fontSize: 25,
                // fontWeight: FontWeight.bold,
                ),
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
