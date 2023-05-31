import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/screens/auth_screens/register_screen.dart';
import 'package:nico/screens/home_screen.dart';
import 'package:nico/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates:  [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('pt', 'BR'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color.fromARGB(255, 15, 15, 15),
              onPrimary: Colors.white,
              secondary: Colors.white,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.white,
              background: Colors.white,
              onBackground: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.montserrat(
                  // fontSize: 25,
                  // fontWeight: FontWeight.bold,
                  ),
              bodyMedium: GoogleFonts.montserrat(
                fontSize: 17,
              ),
              bodySmall: GoogleFonts.montserrat(),
            ),
          ),
          home:  AuthOrAppComponent()),
    );
  }
}
