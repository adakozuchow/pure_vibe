import 'package:flutter/material.dart';
import '../models/character_tile.dart';

class CharacterGrid extends StatelessWidget {
  final List<CharacterTile> tiles;
  final Function(CharacterTile) onTileTap;
  final int crossAxisCount;
  final bool isGuessedGrid;

  const CharacterGrid({
    super.key,
    required this.tiles,
    required this.onTileTap,
    this.crossAxisCount = 4,
    this.isGuessedGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return GestureDetector(
          onTap: isGuessedGrid ? null : () => onTileTap(tile),
          child: Container(
            decoration: BoxDecoration(
              color: isGuessedGrid ? Colors.blue : Colors.green,
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

Future<bool?> showGuessDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 48),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
} 