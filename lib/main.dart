import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/game_page.dart';
import 'providers/game_provider.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(const BombermanApp());
}

class BombermanApp extends StatelessWidget {
  const BombermanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Bomberman Flutter',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const MenuPage(),
          '/game': (context) => const GamePage(),
        },
      ),
    );
  }
}