import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// Page du menu principal
/// Permet de démarrer une nouvelle partie
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    // Pas besoin de pause automatique - le timer est géré explicitement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // S'assurer que le jeu est proprement réinitialisé avant de commencer
            final gameProvider = Provider.of<GameProvider>(context, listen: false);
            gameProvider.resetGame(); // resetGame() gère déjà la pause/reprise du timer
            Navigator.pushNamed(context, '/game');
          },
          child: const Text('Commencer une partie'),
        ),
      ),
    );
  }
}