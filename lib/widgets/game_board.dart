import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/board_tile.dart';

/// Widget affichant le plateau de jeu Bomberman
/// Rendu visuel de la grille avec les joueurs, bombes, bonus et explosions
class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  /// Retourne la couleur appropriée pour chaque type de case
  Color _tileColor(TileType type) {
    switch (type) {
      case TileType.wall:
        return Colors.grey;
      case TileType.destructible:
        return Colors.brown;
      case TileType.bomb:
        return Colors.black;
      case TileType.explosion:
        return Colors.orange;
      case TileType.empty:
      default:
        return Colors.green[200]!;
    }
  }

  /// Retourne l'icône appropriée pour chaque type de bonus
  Widget? _powerUpIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.bombRange:
        return const Icon(Icons.open_with, color: Colors.yellow, size: 24);
      case PowerUpType.bombCount:
        return const Icon(Icons.add_circle, color: Colors.purple, size: 24);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final board = gameProvider.board;
    final players = gameProvider.players;
    return Center(
      child: SizedBox(
        width: boardWidth * 36,
        height: boardHeight * 36,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardWidth,
          ),
          itemCount: boardWidth * boardHeight,
          itemBuilder: (context, index) {
            final x = index % boardWidth;
            final y = index ~/ boardWidth;
            final tile = board[y][x];
            final playerHere = players.where((p) => p.x == x && p.y == y).toList();
            return Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: playerHere.isNotEmpty ? playerHere.first.color : _tileColor(tile.type),
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (tile.powerUp != PowerUpType.none) _powerUpIcon(tile.powerUp)!,
                  if (playerHere.isNotEmpty)
                    Icon(
                      playerHere.length == 1
                        ? Icons.person
                        : Icons.people,
                      color: Colors.white,
                      size: 28,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}