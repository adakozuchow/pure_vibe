import 'package:flutter/material.dart';
import '../models/character_tile.dart';

class CharacterGrid extends StatelessWidget {
  final List<CharacterTile> tiles;
  final Function(CharacterTile) onTileTap;
  final int crossAxisCount;

  const CharacterGrid({
    super.key,
    required this.tiles,
    required this.onTileTap,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out used tiles
    final activeTiles = tiles.where((tile) => !tile.isUsed).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: activeTiles.length,
      itemBuilder: (context, index) {
        final tile = activeTiles[index];
        return GestureDetector(
          onTap: () => onTileTap(tile),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    tile.character,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 