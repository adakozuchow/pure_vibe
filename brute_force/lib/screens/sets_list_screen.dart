import 'package:flutter/material.dart';
import '../models/run.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'new_set_screen.dart';

class SetsListScreen extends StatefulWidget {
  const SetsListScreen({super.key});

  @override
  State<SetsListScreen> createState() => _SetsListScreenState();
}

class _SetsListScreenState extends State<SetsListScreen> {
  late StorageService _storage;
  List<Run> sets = [];

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.init();
    setState(() {
      sets = _storage.loadRuns();
    });
  }

  Future<void> _saveState() async {
    try {
      await _storage.saveRuns(sets);
    } catch (e) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Error'),
          content: Text(
            'Failed to save changes: ${e.toString()}\n\n'
            'Try deleting some existing sets to free up space.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _createNewSet() async {
    final result = await Navigator.push<Run>(
      context,
      MaterialPageRoute(builder: (context) => const NewSetScreen()),
    );

    if (result != null) {
      try {
        setState(() {
          sets.add(result);
        });
        await _saveState();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          // Revert the addition if save failed
          sets.removeLast();
        });
      }
    }
  }

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

  void _openSet(Run set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          initialSet: set,
          onSetUpdated: (updatedSet) {
            setState(() {
              final index = sets.indexWhere((s) => s.id == updatedSet.id);
              if (index != -1) {
                sets[index] = updatedSet;
                _saveState();
              }
            });
          },
        ),
      ),
    );
  }

  String _getCharacterSetDescription(Run set) {
    final options = <String>[];
    if (set.useNumbers) options.add('0-9');
    if (set.useSmallLetters) options.add('a-z');
    if (set.useBigLetters) options.add('A-Z');
    if (set.useSpecialChars) options.add('!@#');
    return options.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BruteForcer'),
      ),
      body: sets.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No Sets Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createNewSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Set'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    set.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Progress: ${set.remainingTiles} / ${set.tiles.length} remaining',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Length: ${set.stringLength} chars • ${_getCharacterSetDescription(set)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSet(set.id),
                  ),
                  onTap: () => _openSet(set),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSet,
        child: const Icon(Icons.add),
      ),
    );
  }
} 