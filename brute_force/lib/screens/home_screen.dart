import 'package:flutter/material.dart';
import '../models/run.dart';
import '../models/character_tile.dart';
import '../widgets/character_grid.dart';
import '../widgets/suggested_tile.dart';

class HomeScreen extends StatefulWidget {
  final Run initialSet;
  final Function(Run) onSetUpdated;

  const HomeScreen({
    super.key,
    required this.initialSet,
    required this.onSetUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Run currentSet;

  @override
  void initState() {
    super.initState();
    currentSet = widget.initialSet;
  }

  void _onTileTap(CharacterTile tile) {
    setState(() {
      tile.markAsUsed();
      widget.onSetUpdated(currentSet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('BruteForcer'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentSet.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining: ${currentSet.remainingTiles}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SuggestedTile(
              tiles: currentSet.tiles,
              onTileTap: _onTileTap,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CharacterGrid(
                tiles: currentSet.tiles,
                onTileTap: _onTileTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 