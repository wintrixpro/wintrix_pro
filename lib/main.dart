import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wintrix_pro/presentation/screens/splash_screen.dart';
import 'package:wintrix_pro/presentation/provider/splash_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // यहाँ अपने firebase_core को इनिशियलाइज़ करना न भूलें अगर इस्तेमाल कर रहे हैं
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
