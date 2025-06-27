import 'dart:math';
import 'character_tile.dart';

class Run {
  final String id;
  final String name;
  final List<CharacterTile> tiles;
  final int stringLength;
  final bool useNumbers;
  final bool useSmallLetters;
  final bool useBigLetters;
  final bool useSpecialChars;

  Run({
    required this.id,
    required this.name,
    required this.stringLength,
    required this.useNumbers,
    required this.useSmallLetters,
    required this.useBigLetters,
    required this.useSpecialChars,
    List<CharacterTile>? tiles,
  }) : tiles = tiles ?? [];

  static List<String> _generateCharacterSet({
    required bool useNumbers,
    required bool useSmallLetters,
    required bool useBigLetters,
    required bool useSpecialChars,
  }) {
    final charSet = <String>[];
    
    if (useNumbers) charSet.addAll(['0','1','2','3','4','5','6','7','8','9']);
    if (useSmallLetters) charSet.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
    if (useBigLetters) charSet.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    if (useSpecialChars) charSet.addAll('!@#\$%^&*()_+-=[]{}|;:,.<>?'.split(''));

    if (charSet.isEmpty) {
      throw ArgumentError('At least one character set must be selected');
    }

    return charSet;
  }

  static List<String> generatePermutations({
    required int length,
    required List<String> charSet,
  }) {
    List<String> result = [''];
    
    for (int i = 0; i < length; i++) {
      List<String> newResult = [];
      for (String current in result) {
        for (String char in charSet) {
          newResult.add(current + char);
        }
      }
      result = newResult;
    }
    
    return result;
  }

  static int calculatePermutationsCount({
    required int length,
    required bool useNumbers,
    required bool useSmallLetters,
    required bool useBigLetters,
    required bool useSpecialChars,
  }) {
    int charSetSize = 0;
    if (useNumbers) charSetSize += 10;
    if (useSmallLetters) charSetSize += 26;
    if (useBigLetters) charSetSize += 26;
    if (useSpecialChars) charSetSize += 23; // Number of special characters
    
    if (charSetSize == 0) return 0;
    return pow(charSetSize, length).toInt();
  }

  factory Run.generate({
    required String name,
    required int stringLength,
    required bool useNumbers,
    required bool useSmallLetters,
    required bool useBigLetters,
    required bool useSpecialChars,
  }) {
    final charSet = _generateCharacterSet(
      useNumbers: useNumbers,
      useSmallLetters: useSmallLetters,
      useBigLetters: useBigLetters,
      useSpecialChars: useSpecialChars,
    );

    final permutations = generatePermutations(
      length: stringLength,
      charSet: charSet,
    );

    return Run(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      stringLength: stringLength,
      useNumbers: useNumbers,
      useSmallLetters: useSmallLetters,
      useBigLetters: useBigLetters,
      useSpecialChars: useSpecialChars,
      tiles: List.generate(
        permutations.length,
        (index) => CharacterTile(
          character: permutations[index],
          position: index,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stringLength': stringLength,
    'useNumbers': useNumbers,
    'useSmallLetters': useSmallLetters,
    'useBigLetters': useBigLetters,
    'useSpecialChars': useSpecialChars,
    'tiles': tiles.map((tile) => {
      'character': tile.character,
      'position': tile.position,
      'isUsed': tile.isUsed,
    }).toList(),
  };

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'],
      name: json['name'],
      stringLength: json['stringLength'],
      useNumbers: json['useNumbers'],
      useSmallLetters: json['useSmallLetters'],
      useBigLetters: json['useBigLetters'],
      useSpecialChars: json['useSpecialChars'] ?? false, // Default for backward compatibility
      tiles: (json['tiles'] as List).map((tile) => CharacterTile(
        character: tile['character'],
        position: tile['position'],
        isUsed: tile['isUsed'],
      )).toList(),
    );
  }

  int get remainingTiles => tiles.where((tile) => !tile.isUsed).length;
  bool get isCompleted => remainingTiles == 0;
} 