import 'package:flutter/material.dart';
import '../models/run.dart';
import '../models/character_tile.dart';
import '../widgets/character_grid.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storage;
  List<Run> runs = [];
  String? currentRunId;
  int stringLength = 2; // Starting with smaller length due to permutations
  bool useNumbers = true;
  bool useSmallLetters = false;
  bool useBigLetters = false;
  final TextEditingController _runNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.init();
    setState(() {
      runs = _storage.loadRuns();
      currentRunId = _storage.loadCurrentRunId();
    });
  }

  Future<void> _saveState() async {
    await _storage.saveRuns(runs);
    await _storage.saveCurrentRunId(currentRunId);
  }

  void _createNewRun() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Run'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _runNameController,
              decoration: const InputDecoration(
                labelText: 'Run Name',
                hintText: 'Enter a name for this run',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will generate ${Run.calculatePermutationsCount(
                length: stringLength,
                useNumbers: useNumbers,
                useSmallLetters: useSmallLetters,
                useBigLetters: useBigLetters,
              )} permutations',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_runNameController.text.isNotEmpty) {
                setState(() {
                  final newRun = Run.generate(
                    name: _runNameController.text,
                    stringLength: stringLength,
                    useNumbers: useNumbers,
                    useSmallLetters: useSmallLetters,
                    useBigLetters: useBigLetters,
                  );
                  runs.add(newRun);
                  currentRunId = newRun.id;
                  _saveState();
                });
                _runNameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _onTileTap(CharacterTile tile) {
    setState(() {
      tile.markAsUsed();
      _saveState();
    });
  }

  Run? get currentRun => currentRunId != null 
    ? runs.firstWhere((run) => run.id == currentRunId)
    : null;

  int get permutationsCount => Run.calculatePermutationsCount(
    length: stringLength,
    useNumbers: useNumbers,
    useSmallLetters: useSmallLetters,
    useBigLetters: useBigLetters,
  );

  void _deleteRun(String runId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Run'),
        content: const Text('Are you sure you want to delete this run?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                runs.removeWhere((run) => run.id == runId);
                if (currentRunId == runId) {
                  currentRunId = runs.isNotEmpty ? runs.last.id : null;
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
          if (runs.isNotEmpty)
            PopupMenuButton<String>(
              initialValue: currentRunId,
              onSelected: (id) {
                setState(() {
                  currentRunId = id;
                  _saveState();
                });
              },
              itemBuilder: (BuildContext context) {
                return runs.map((run) {
                  return PopupMenuItem<String>(
                    value: run.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(run.name),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteRun(run.id);
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
                      currentRun?.name ?? 'Select Run',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('String Length: '),
                        Expanded(
                          child: Slider(
                            value: stringLength.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: stringLength.toString(),
                            onChanged: (value) {
                              setState(() {
                                stringLength = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(stringLength.toString()),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('Numbers (0-9)'),
                      value: useNumbers,
                      onChanged: (value) {
                        setState(() => useNumbers = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Small Letters (a-z)'),
                      value: useSmallLetters,
                      onChanged: (value) {
                        setState(() => useSmallLetters = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Big Letters (A-Z)'),
                      value: useBigLetters,
                      onChanged: (value) {
                        setState(() => useBigLetters = value ?? false);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Number of permutations: $permutationsCount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (currentRun != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CharacterGrid(
                      tiles: currentRun!.tiles,
                      onTileTap: _onTileTap,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRun,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _runNameController.dispose();
    super.dispose();
  }
} 