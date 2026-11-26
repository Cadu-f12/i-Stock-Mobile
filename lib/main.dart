import 'package:flutter/material.dart';
import 'package:i_stock_mobile/views/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'I-STOCK',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF34458F)),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
    ),
    home: const LoginPage(),
  );
}
