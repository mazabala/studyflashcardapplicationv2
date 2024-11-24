import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchAndDisplayDifficultyLevelWidget extends StatelessWidget {
  final String? selectedDifficulty;
  final ValueChanged<String?> onChanged;
  final Future<List<String>> Function() fetchDifficulty;

  const FetchAndDisplayDifficultyLevelWidget({
    Key? key,
    required this.selectedDifficulty,
    required this.onChanged,
    required this.fetchDifficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<String>>(
          future: fetchDifficulty(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final difficultyLevels = snapshot.data!;
              return DropdownButton<String>(
                value: selectedDifficulty,
                onChanged: onChanged,
                items: difficultyLevels
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            } else {
              return Text('No difficulty levels available');
            }
          },
        );
      },
    );
  }
}
