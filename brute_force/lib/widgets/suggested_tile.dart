import 'package:flutter/material.dart';
import '../models/character_tile.dart';
import 'dart:math';

class SuggestedTile extends StatefulWidget {
  final List<CharacterTile> tiles;
  final Function(CharacterTile) onTileTap;

  const SuggestedTile({
    super.key,
    required this.tiles,
    required this.onTileTap,
  });

  @override
  State<SuggestedTile> createState() => _SuggestedTileState();
}

class _SuggestedTileState extends State<SuggestedTile> {
  late CharacterTile _suggestedTile;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pickRandomTile();
  }

  @override
  void didUpdateWidget(SuggestedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pickRandomTile();
  }

  void _pickRandomTile() {
    final activeTiles = widget.tiles.where((tile) => !tile.isUsed).toList();
    if (activeTiles.isNotEmpty) {
      _suggestedTile = activeTiles[_random.nextInt(activeTiles.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTiles = widget.tiles.where((tile) => !tile.isUsed).toList();
    if (activeTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Suggested String',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                widget.onTileTap(_suggestedTile);
                _pickRandomTile();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _suggestedTile.character,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _pickRandomTile();
                });
              },
              child: const Text('Try Another'),
            ),
          ],
        ),
      ),
    );
  }
} 