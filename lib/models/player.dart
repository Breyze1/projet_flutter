import 'package:flutter/material.dart';

class Player {
  int x;
  int y;
  final int id;
  final Color color;
  int bombRange;
  int maxBombs;
  int activeBombs;
  int lives;

  Player({
    required this.x,
    required this.y,
    required this.id,
    required this.color,
    this.bombRange = 2,
    this.maxBombs = 1,
    this.activeBombs = 0,
    this.lives = 3,
  });
}