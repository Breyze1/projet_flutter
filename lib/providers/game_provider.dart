import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/board_tile.dart';

const int boardWidth = 15;
const int boardHeight = 13;

/// Représente une bombe placée sur le plateau
class Bomb {
  final int x;
  final int y;
  int timer; // en ticks
  final int range;
  final int ownerId;
  Bomb({required this.x, required this.y, required this.range, required this.ownerId, this.timer = 3});
}

/// Gestionnaire principal du jeu Bomberman
/// Contient toute la logique de jeu, l'état des joueurs et du plateau
class GameProvider with ChangeNotifier {
  List<Player> players = [
    Player(x: boardWidth - 2, y: 1, id: 1, color: Colors.blue), // Joueur bleu à droite
    Player(x: 1, y: boardHeight - 2, id: 2, color: Colors.red),  // Joueur rouge à gauche
  ];
  List<List<BoardTile>> board = List.generate(
    boardHeight,
    (i) => List.generate(boardWidth, (j) => BoardTile(x: j, y: i, type: TileType.empty)),
  );
  List<Bomb> bombs = [];
  List<bool> playerDead = [false, false];
  bool gameOver = false;
  int? winnerId;
  Timer? _bombTimer;
  Random _rand = Random();

  GameProvider() {
    _initWalls();
    _startBombTimer();
    _spawnRandomPowerUps(8);
  }

  /// Réinitialise complètement le jeu pour une nouvelle partie
  void resetGame() {
    // Annuler le timer existant
    _bombTimer?.cancel();
    _bombTimer = null;
    
    // Réinitialiser les joueurs
    players[0] = Player(x: boardWidth - 2, y: 1, id: 1, color: Colors.blue);
    players[1] = Player(x: 1, y: boardHeight - 2, id: 2, color: Colors.red);
    
    // Réinitialiser l'état du jeu
    bombs.clear();
    playerDead = [false, false];
    gameOver = false;
    winnerId = null;
    
    // Générer un nouveau plateau
    board = List.generate(
      boardHeight,
      (i) => List.generate(boardWidth, (j) => BoardTile(x: j, y: i, type: TileType.empty)),
    );
    
    _initWalls();
    _spawnRandomPowerUps(8);
    
    // Démarrer un nouveau timer propre
    _startBombTimer();
    
    notifyListeners();
  }

  /// Initialise les murs et les blocs destructibles sur le plateau
  void _initWalls() {
    // Murs de bordure
    for (int i = 0; i < boardHeight; i++) {
      board[i][0].type = TileType.wall;
      board[i][boardWidth - 1].type = TileType.wall;
    }
    for (int j = 0; j < boardWidth; j++) {
      board[0][j].type = TileType.wall;
      board[boardHeight - 1][j].type = TileType.wall;
    }
    // Murs statiques internes (tous les deux cases)
    for (int i = 2; i < boardHeight - 1; i += 2) {
      for (int j = 2; j < boardWidth - 1; j += 2) {
        board[i][j].type = TileType.wall;
      }
    }
    // Blocs destructibles, mais laisser les zones de spawn libres
    for (int i = 1; i < boardHeight - 1; i++) {
      for (int j = 1; j < boardWidth - 1; j++) {
        if (board[i][j].type == TileType.empty && !_isInSpawnArea(j, i)) {
          if (_rand.nextDouble() < 0.6) {
            board[i][j].type = TileType.destructible;
          }
        }
      }
    }
  }

  /// Vérifie si une position est dans une zone de spawn
  bool _isInSpawnArea(int x, int y) {
    // Zone de spawn du joueur 1 (haut-droite)
    if ((x >= boardWidth - 3 && y <= 2)) return true;
    // Zone de spawn du joueur 2 (bas-gauche)
    if ((x <= 2 && y >= boardHeight - 3)) return true;
    return false;
  }

  /// Fait apparaître des bonus aléatoires sur le plateau
  void _spawnRandomPowerUps(int count) {
    int placed = 0;
    while (placed < count) {
      int x = _rand.nextInt(boardWidth - 2) + 1;
      int y = _rand.nextInt(boardHeight - 2) + 1;
      if (board[y][x].type == TileType.destructible && board[y][x].powerUp == PowerUpType.none) {
        board[y][x].powerUp = _rand.nextBool() ? PowerUpType.bombRange : PowerUpType.bombCount;
        placed++;
      }
    }
  }

  Player get player1 => players[0];
  Player get player2 => players[1];

  /// Déplace un joueur dans la direction spécifiée
  void movePlayer(int playerIdx, int dx, int dy) {
    if (playerDead[playerIdx] || gameOver) return;
    Player player = players[playerIdx];
    int newX = player.x + dx;
    int newY = player.y + dy;
    if (newX < 0 || newX >= boardWidth || newY < 0 || newY >= boardHeight) return;
    if (board[newY][newX].type == TileType.wall || board[newY][newX].type == TileType.destructible || board[newY][newX].type == TileType.bomb) return;
    player.x = newX;
    player.y = newY;
    _pickupPowerUp(player);
    notifyListeners();
  }

  /// Ramasse un bonus si le joueur se trouve dessus
  void _pickupPowerUp(Player player) {
    var tile = board[player.y][player.x];
    if (tile.powerUp == PowerUpType.bombRange) {
      player.bombRange++;
      tile.powerUp = PowerUpType.none;
    } else if (tile.powerUp == PowerUpType.bombCount) {
      player.maxBombs++;
      tile.powerUp = PowerUpType.none;
    }
  }

  /// Place une bombe pour le joueur spécifié
  void placeBomb(int playerIdx) {
    if (playerDead[playerIdx] || gameOver) return;
    Player player = players[playerIdx];
    if (board[player.y][player.x].type == TileType.bomb) return;
    if (player.activeBombs >= player.maxBombs) return;
    bombs.add(Bomb(x: player.x, y: player.y, range: player.bombRange, ownerId: player.id));
    board[player.y][player.x].type = TileType.bomb;
    player.activeBombs++;
    notifyListeners();
  }

  /// Démarre la boucle de timer pour les bombes
  void _startBombTimer() {
    // Annuler le timer existant s'il y en a un
    _bombTimer?.cancel();
    _bombTimer = null;
    
    // Ne démarrer le timer que s'il y a des bombes ou si le jeu n'est pas fini
    if (!gameOver) {
      _bombTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (!gameOver && bombs.isNotEmpty) {
          _tickBombs();
        }
      });
    }
  }

  /// Met à jour le timer de toutes les bombes
  void _tickBombs() {
    if (bombs.isEmpty) return; // Optimisation: ne rien faire s'il n'y a pas de bombes
    
    List<Bomb> exploded = [];
    for (var bomb in bombs) {
      bomb.timer--;
      if (bomb.timer <= 0) {
        exploded.add(bomb);
      }
    }
    
    if (exploded.isNotEmpty) {
      for (var bomb in exploded) {
        _explode(bomb);
        bombs.remove(bomb);
        var owner = players.firstWhere((p) => p.id == bomb.ownerId, orElse: () => players[0]);
        owner.activeBombs = (owner.activeBombs - 1).clamp(0, owner.maxBombs);
      }
      notifyListeners();
    }
  }

  /// Fait exploser une bombe et affecte les cases environnantes
  void _explode(Bomb bomb) {
    board[bomb.y][bomb.x].type = TileType.explosion;
    _checkPlayerHit(bomb.x, bomb.y);
    for (var dir in [const [0,1], const [0,-1], const [1,0], const [-1,0]]) {
      for (int i = 1; i <= bomb.range; i++) {
        int nx = bomb.x + dir[0]*i;
        int ny = bomb.y + dir[1]*i;
        if (nx < 0 || nx >= boardWidth || ny < 0 || ny >= boardHeight) break;
        if (board[ny][nx].type == TileType.wall) break;
        board[ny][nx].type = TileType.explosion;
        _checkPlayerHit(nx, ny);
        if (board[ny][nx].type == TileType.destructible) {
          board[ny][nx].type = TileType.explosion;
          if (_rand.nextDouble() < 0.2) {
            board[ny][nx].powerUp = _rand.nextBool() ? PowerUpType.bombRange : PowerUpType.bombCount;
          }
          break;
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      _clearExplosions();
      notifyListeners();
    });
  }

  /// Efface toutes les explosions du plateau
  void _clearExplosions() {
    for (var row in board) {
      for (var tile in row) {
        if (tile.type == TileType.explosion) {
          tile.type = TileType.empty;
        }
      }
    }
  }

  /// Vérifie si un joueur est touché par une explosion
  void _checkPlayerHit(int x, int y) {
    for (int i = 0; i < players.length; i++) {
      if (players[i].x == x && players[i].y == y && !playerDead[i]) {
        playerDead[i] = true;
        players[i].lives--;
        
        if (players[i].lives <= 0) {
          // Fin de partie
          gameOver = true;
          winnerId = players[1 - i].id; // L'autre joueur gagne
          notifyListeners();
          return; // Sortir tôt pour éviter la logique de réapparition
        } else {
          // Réapparition après délai
          Future.delayed(const Duration(seconds: 1), () {
            if (!gameOver) { // Seulement réapparaître si le jeu n'est pas fini
              _resetPlayer(i);
              notifyListeners();
            }
          });
        }
        notifyListeners();
        return; // Sortir après avoir géré un coup sur un joueur
      }
    }
  }

  /// Réinitialise un joueur à une position sûre
  void _resetPlayer(int idx) {
    // Trouver une position de réapparition sûre
    var respawnPos = _findSafeRespawnPosition(idx);
    players[idx].x = respawnPos[0];
    players[idx].y = respawnPos[1];
    playerDead[idx] = false;
    players[idx].bombRange = 2;
    players[idx].maxBombs = 1;
    players[idx].activeBombs = 0;
  }

  /// Trouve une position de réapparition sûre à l'opposé du joueur vivant
  List<int> _findSafeRespawnPosition(int deadPlayerIdx) {
    int alivePlayerIdx = 1 - deadPlayerIdx;
    var alivePlayer = players[alivePlayerIdx];
    
    // Déterminer de quel côté réapparaître (opposé au joueur vivant)
    bool spawnOnLeft = alivePlayer.x > boardWidth / 2;
    bool spawnOnTop = alivePlayer.y > boardHeight / 2;
    
    List<List<int>> possiblePositions = [];
    
    // Trouver toutes les positions sûres du côté approprié
    for (int y = 1; y < boardHeight - 1; y++) {
      for (int x = 1; x < boardWidth - 1; x++) {
        // Vérifier si la position est du bon côté
        bool onCorrectSide = false;
        if (spawnOnLeft && x < boardWidth / 2) onCorrectSide = true;
        if (!spawnOnLeft && x > boardWidth / 2) onCorrectSide = true;
        if (spawnOnTop && y < boardHeight / 2) onCorrectSide = true;
        if (!spawnOnTop && y > boardHeight / 2) onCorrectSide = true;
        
        if (onCorrectSide) {
          // Vérifier si la position est sûre (vide, non occupée, et a au moins une case libre adjacente)
          if (board[y][x].type == TileType.empty && 
              !_isPositionOccupied(x, y) &&
              _hasAdjacentFreeSpace(x, y)) {
            possiblePositions.add([x, y]);
          }
        }
      }
    }
    
    // Si aucune position sûre trouvée du côté opposé, utiliser les spawns par défaut
    if (possiblePositions.isEmpty) {
      if (deadPlayerIdx == 0) {
        return [boardWidth - 2, 1]; // Position par défaut du joueur bleu
      } else {
        return [1, boardHeight - 2]; // Position par défaut du joueur rouge
      }
    }
    
    // Retourner une position sûre aléatoire
    return possiblePositions[_rand.nextInt(possiblePositions.length)];
  }

  /// Vérifie si une position est occupée par un joueur
  bool _isPositionOccupied(int x, int y) {
    for (var player in players) {
      if (player.x == x && player.y == y) {
        return true;
      }
    }
    return false;
  }

  /// Vérifie si une position a au moins une case libre adjacente pour le mouvement
  bool _hasAdjacentFreeSpace(int x, int y) {
    // Vérifier les 4 directions (haut, bas, gauche, droite)
    List<List<int>> directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    
    for (var dir in directions) {
      int nx = x + dir[0];
      int ny = y + dir[1];
      
      // Vérifier que la position est dans les limites
      if (nx >= 0 && nx < boardWidth && ny >= 0 && ny < boardHeight) {
        // Vérifier que la case adjacente est libre (vide ou destructible)
        if (board[ny][nx].type == TileType.empty || board[ny][nx].type == TileType.destructible) {
          return true;
        }
      }
    }
    return false;
  }

  void dispose() {
    _bombTimer?.cancel();
    _bombTimer = null;
  }
}