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
    await _storage.saveRuns(sets);
  }

  void _createNewSet() async {
    final result = await Navigator.push<Run>(
      context,
      MaterialPageRoute(builder: (context) => const NewSetScreen()),
    );

    if (result != null) {
      setState(() {
        sets.add(result);
        _saveState();
      });
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
                  subtitle: Text(
                    'Remaining: ${set.remainingTiles} / ${set.tiles.length}',
                  ),
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