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

  Future<bool> _showConfirmationDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Color _getPermutationCountColor() {
    if (permutationsCount > 2000) {
      return Colors.red;
    }
    return Colors.green.shade800;
  }

  Future<void> _createSet() async {
    final name = _setNameController.text.trim();
    
    if (name.isEmpty) {
      _showWarningDialog('Please provide a name for the set.');
      return;
    }

    if (!_isNameUnique(name)) {
      _showWarningDialog('A set with this name already exists. Please choose a different name.');
      return;
    }

    // Create the set first to check storage requirements
    final newSet = Run.generate(
      name: name,
      stringLength: stringLength,
      useNumbers: useNumbers,
      useSmallLetters: useSmallLetters,
      useBigLetters: useBigLetters,
      useSpecialChars: useSpecialChars,
    );

    // Check storage space before showing other warnings
    final hasSpace = await _storage.hasEnoughSpaceForRun(newSet);
    if (!hasSpace) {
      _showWarningDialog(
        'Cannot create this set: Storage quota exceeded.\n\n'
        'The set is too large to store. Try reducing the string length '
        'or using fewer character types.\n\n'
        'You can also delete some existing sets to free up space.'
      );
      return;
    }

    if (permutationsCount > 100000) {
      _showWarningDialog(
        'Warning: Generating more than 100,000 permutations may impact application performance and stability.'
      );
    }

    if (permutationsCount > 9999) {
      final confirmed = await _showConfirmationDialog(
        'You are about to generate ${permutationsCount.toString()} permutations. '
        'This is a large number that may affect application performance and storage space. '
        'Are you sure you want to continue?'
      );
      
      if (!confirmed) {
        return;
      }
    }

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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _getPermutationCountColor(),
                fontWeight: FontWeight.bold,
              ),
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