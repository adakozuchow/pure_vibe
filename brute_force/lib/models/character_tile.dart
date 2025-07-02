import 'package:flutter/material.dart';

class CharacterTile {
  final String character;
  bool isUsed;
  bool isGuessed;
  final int position;

  CharacterTile({
    required this.character,
    this.isUsed = false,
    this.isGuessed = false,
    required this.position,
  });

  void markAsUsed() {
    isUsed = true;
  }

  void markAsGuessed() {
    isUsed = true;
    isGuessed = true;
  }
} 