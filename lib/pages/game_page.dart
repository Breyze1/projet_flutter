import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_board.dart';
import '../providers/game_provider.dart';
import 'package:flutter/services.dart';

/// Page principale du jeu Bomberman
/// Gère l'affichage du plateau de jeu, les contrôles clavier et l'interface utilisateur
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<bool> _wasDead = [false, false];
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Le timer est déjà géré par resetGame() dans le menu
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<GameProvider>(context, listen: false).addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    Provider.of<GameProvider>(context, listen: false).removeListener(_onProviderUpdate);
    _focusNode.dispose();
    super.dispose();
  }

  /// Gère les mises à jour du provider (mort des joueurs, etc.)
  void _onProviderUpdate() {
    final provider = Provider.of<GameProvider>(context, listen: false);
    for (int i = 0; i < provider.players.length; i++) {
      if (provider.playerDead[i] && !_wasDead[i]) {
        _wasDead[i] = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joueur ${i + 1} est mort ! Réapparition...'), duration: const Duration(milliseconds: 800)),
        );
      } else if (!provider.playerDead[i] && _wasDead[i]) {
        _wasDead[i] = false;
      }
    }
  }

  /// Gère les entrées clavier pour les deux joueurs
  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    // Joueur 1: Flèches + Shift pour bombe
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      gameProvider.movePlayer(0, 0, -1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      gameProvider.movePlayer(0, 0, 1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      gameProvider.movePlayer(0, -1, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      gameProvider.movePlayer(0, 1, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
      gameProvider.placeBomb(0);
    }
    // Joueur 2: ZQSD + Espace pour bombe
    else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      gameProvider.movePlayer(1, 0, -1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      gameProvider.movePlayer(1, 0, 1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
      gameProvider.movePlayer(1, -1, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      gameProvider.movePlayer(1, 1, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      gameProvider.placeBomb(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final players = gameProvider.players;
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Jeu Bomberman')),
        body: Stack(
          children: [
            Row(
              children: [
                // Côté gauche - Statistiques du joueur rouge
                Container(
                  width: 160,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playerStats(players[1], 'Joueur 2 (Rouge)'),
                      const SizedBox(height: 30),
                      _controlsPanel('ZQSD pour bouger', 'Espace pour bombe'),
                    ],
                  ),
                ),
                // Centre - Plateau de jeu
                const Expanded(child: GameBoard()),
                // Côté droit - Statistiques du joueur bleu
                Container(
                  width: 160,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playerStats(players[0], 'Joueur 1 (Bleu)'),
                      const SizedBox(height: 30),
                      _controlsPanel('Flèches pour bouger', 'Shift pour bombe'),
                    ],
                  ),
                ),
              ],
            ),
            // Overlay de fin de partie
            if (gameProvider.gameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${gameProvider.winnerId == 1 ? 'Bleu' : 'Rouge'} gagne !',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: gameProvider.winnerId == 1 ? Colors.blue : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              gameProvider.resetGame();
                            },
                            child: const Text('Rejouer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Widget affichant les statistiques d'un joueur (vies, bombes, portée)
  Widget _playerStats(player, String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: player.color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: player.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Affichage des vies
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => 
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  index < player.lives ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Statistiques
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 20, color: Colors.red),
                  Text('${player.maxBombs}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Bombes', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.open_with, size: 20, color: Colors.yellow),
                  Text('${player.bombRange}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Portée', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget affichant les contrôles pour chaque joueur
  Widget _controlsPanel(String moveText, String bombText) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const Text(
            'Contrôles',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            moveText,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            bombText,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}