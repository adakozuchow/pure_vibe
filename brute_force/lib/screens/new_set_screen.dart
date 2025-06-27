import 'package:flutter/material.dart';
import '../models/run.dart';

class NewSetScreen extends StatefulWidget {
  const NewSetScreen({super.key});

  @override
  State<NewSetScreen> createState() => _NewSetScreenState();
}

class _NewSetScreenState extends State<NewSetScreen> {
  final TextEditingController _setNameController = TextEditingController();
  int stringLength = 2;
  bool useNumbers = true;
  bool useSmallLetters = false;
  bool useBigLetters = false;
  bool useSpecialChars = false;

  int get permutationsCount => Run.calculatePermutationsCount(
    length: stringLength,
    useNumbers: useNumbers,
    useSmallLetters: useSmallLetters,
    useBigLetters: useBigLetters,
    useSpecialChars: useSpecialChars,
  );

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
              ),
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
              onPressed: () {
                if (_setNameController.text.isNotEmpty) {
                  final newSet = Run.generate(
                    name: _setNameController.text,
                    stringLength: stringLength,
                    useNumbers: useNumbers,
                    useSmallLetters: useSmallLetters,
                    useBigLetters: useBigLetters,
                    useSpecialChars: useSpecialChars,
                  );
                  Navigator.pop(context, newSet);
                }
              },
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