import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchAndDisplayCategorySelectionWidget extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final Future<List<String>> Function() fetchCategory;

  const FetchAndDisplayCategorySelectionWidget({
    Key? key,
    required this.selectedCategory,
    required this.onChanged,
    required this.fetchCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<String>>(
          future: fetchCategory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final categories = snapshot.data!;
              return DropdownButton<String>(
                value: selectedCategory,
                onChanged: onChanged,
                items: categories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            } else {
              return const Text('No categories available');
            }
          },
        );
      },
    );
  }
}
