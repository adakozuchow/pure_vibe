import 'package:flutter/material.dart';
import '../models/run.dart';
import '../models/character_tile.dart';
import '../widgets/character_grid.dart';
import '../services/storage_service.dart';
import 'new_set_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storage;
  List<Run> sets = [];
  String? currentSetId;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.init();
    setState(() {
      sets = _storage.loadRuns();
      currentSetId = _storage.loadCurrentRunId();
    });
  }

  Future<void> _saveState() async {
    await _storage.saveRuns(sets);
    await _storage.saveCurrentRunId(currentSetId);
  }

  void _createNewSet() async {
    final result = await Navigator.push<Run>(
      context,
      MaterialPageRoute(builder: (context) => const NewSetScreen()),
    );

    if (result != null) {
      setState(() {
        sets.add(result);
        currentSetId = result.id;
        _saveState();
      });
    }
  }

  void _onTileTap(CharacterTile tile) {
    setState(() {
      tile.markAsUsed();
      _saveState();
    });
  }

  Run? get currentSet => currentSetId != null 
    ? sets.firstWhere((set) => set.id == currentSetId)
    : null;

  void _deleteSet(String setId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Set'),
        content: const Text('Are you sure you want to delete this set?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                sets.removeWhere((set) => set.id == setId);
                if (currentSetId == setId) {
                  currentSetId = sets.isNotEmpty ? sets.last.id : null;
                }
                _saveState();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pure Vibe'),
        actions: [
          if (sets.isNotEmpty)
            PopupMenuButton<String>(
              initialValue: currentSetId,
              onSelected: (id) {
                setState(() {
                  currentSetId = id;
                  _saveState();
                });
              },
              itemBuilder: (BuildContext context) {
                return sets.map((set) {
                  return PopupMenuItem<String>(
                    value: set.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(set.name),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteSet(set.id);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      currentSet?.name ?? 'Select Set',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: currentSet != null
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Remaining: ${currentSet!.remainingTiles}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CharacterGrid(
                    tiles: currentSet!.tiles,
                    onTileTap: _onTileTap,
                  ),
                ),
              ],
            ),
          )
        : const Center(
            child: Text('Create a new set to get started'),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSet,
        child: const Icon(Icons.add),
      ),
    );
  }
} 