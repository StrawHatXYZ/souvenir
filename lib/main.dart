import 'package:flutter/material.dart';
import 'package:souvenir/providers/scanner_state_provider.dart';
import 'package:souvenir/screens/home.dart';
import 'package:souvenir/providers/screen_provider.dart';
import 'package:souvenir/providers/wallet_state_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletStateProvider()),
        ChangeNotifierProvider(create: (_) => ScreenProvider()),
        ChangeNotifierProvider(create: (_) => ScannerStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phantom Dart Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF324bcd),
          elevation: 5.0,
          shadowColor: Colors.black87,
        ),
        textTheme: Typography().black,
        primaryTextTheme: Typography().black,
        primaryColor: const Color(0xFF324bcd),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF324bcd),
            foregroundColor: Colors.white,
            elevation: 5.0,
            shadowColor: Colors.black87,
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
