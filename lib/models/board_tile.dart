enum TileType { empty, wall, destructible, bomb, explosion }

enum PowerUpType { none, bombRange, bombCount }

class BoardTile {
  final int x;
  final int y;
  TileType type;
  PowerUpType powerUp;

  BoardTile({required this.x, required this.y, this.type = TileType.empty, this.powerUp = PowerUpType.none});
}