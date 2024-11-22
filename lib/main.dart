import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'provider/chat_provider.dart';
import 'constants.dart';

void main() {
  // Gemini SDK.
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MaterialApp(
        color: Colors.red,
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
