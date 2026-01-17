import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/common/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix Intl locale error (DateFormat / NumberFormat)
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katering Pre-Order',
      debugShowCheckedModeBanner: false,

      // Localization (biar format tanggal/angka aman + komponen Flutter ikut)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en')],

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6D28D9), // ungu
      ),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
