import 'package:flutter/material.dart';

class CharacterTile {
  final String character;
  bool isUsed;
  final int position;

  CharacterTile({
    required this.character,
    this.isUsed = false,
    required this.position,
  });

  void markAsUsed() {
    isUsed = true;
  }
} 