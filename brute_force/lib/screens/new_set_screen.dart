import 'package:flutter/material.dart';
import '../models/run.dart';
import '../services/storage_service.dart';

class NewSetScreen extends StatefulWidget {
  const NewSetScreen({super.key});

  @override
  State<NewSetScreen> createState() => _NewSetScreenState();
}

class _NewSetScreenState extends State<NewSetScreen> {
  final TextEditingController _setNameController = TextEditingController();
  late StorageService _storage;
  List<Run> existingSets = [];
  int stringLength = 2;
  bool useNumbers = true;
  bool useSmallLetters = false;
  bool useBigLetters = false;
  bool useSpecialChars = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.init();
    setState(() {
      existingSets = _storage.loadRuns();
    });
  }

  int get permutationsCount => Run.calculatePermutationsCount(
    length: stringLength,
    useNumbers: useNumbers,
    useSmallLetters: useSmallLetters,
    useBigLetters: useBigLetters,
    useSpecialChars: useSpecialChars,
  );

  bool _isNameUnique(String name) {
    return !existingSets.any((set) => 
      set.name.toLowerCase() == name.toLowerCase()
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _createSet() {
    final name = _setNameController.text.trim();
    
    if (name.isEmpty) {
      _showWarningDialog('Please provide a name for the set.');
      return;
    }

    if (!_isNameUnique(name)) {
      _showWarningDialog('A set with this name already exists. Please choose a different name.');
      return;
    }

    final newSet = Run.generate(
      name: name,
      stringLength: stringLength,
      useNumbers: useNumbers,
      useSmallLetters: useSmallLetters,
      useBigLetters: useBigLetters,
      useSpecialChars: useSpecialChars,
    );
    Navigator.pop(context, newSet);
  }

  @override
  void dispose() {
    _setNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Set'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _setNameController,
              decoration: const InputDecoration(
                labelText: 'Set Name',
                hintText: 'Enter a name for this set',
                border: OutlineInputBorder(),
                helperText: 'Name is required and must be unique',
                helperMaxLines: 2,
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 24),
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
                    max: 10,
                    divisions: 9,
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
            CheckboxListTile(
              title: const Text('Special Characters (!@#\$%^&*...)'),
              value: useSpecialChars,
              onChanged: (value) {
                setState(() => useSpecialChars = value ?? false);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'This will generate $permutationsCount permutations',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createSet,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Create Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 