import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';

class DeckFormData {
  final TextEditingController topicController;
  final TextEditingController focusController;
  final TextEditingController cardCountController;
  String? selectedCategory;
  String? selectedDifficulty;

  DeckFormData()
      : topicController = TextEditingController(),
        focusController = TextEditingController(),
        cardCountController = TextEditingController(text: '10');

  void dispose() {
    topicController.dispose();
    focusController.dispose();
    cardCountController.dispose();
  }

  bool isValid() {
    return topicController.text.isNotEmpty &&
        selectedCategory != null &&
        selectedDifficulty != null &&
        cardCountController.text.isNotEmpty;
  }
}

class DeckFormCard extends ConsumerWidget {
  final DeckFormData formData;
  final int index;
  final bool canDelete;
  final VoidCallback? onDelete;
  final List<String>? categories;
  final List<String>? difficulties;

  const DeckFormCard({
    super.key,
    required this.formData,
    required this.index,
    this.canDelete = false,
    this.onDelete,
    this.categories,
    this.difficulties,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 12),
            const SizedBox(height: 10),
            _buildTitleField(),
            const SizedBox(height: 10),
            _buildDescriptionField(),
            const SizedBox(height: 10),
            _buildCategoryDropdown(ref),
            const SizedBox(height: 10),
            _buildDifficultyDropdown(ref),
            const SizedBox(height: 10),
            _buildCardCountField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Deck ${index + 1}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete, size: 24, color: Colors.red),
            onPressed: onDelete,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: formData.topicController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Topic *',
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: formData.focusController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Focus/Concept *',
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: 1,
    );
  }

  Widget _buildCategoryDropdown(WidgetRef ref) {
    // If categories are passed directly, use them
    if (categories != null && categories!.isNotEmpty) {
      // Ensure selectedCategory is valid
      if (formData.selectedCategory == null ||
          !categories!.contains(formData.selectedCategory)) {
        // Set it to the first item in the list
        formData.selectedCategory = categories!.first;
      }

      // Create a Set to ensure unique values
      final uniqueCategories = categories!.toSet().toList();

      return DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(10),
        value: formData.selectedCategory,
        isDense: true,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Category *',
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: uniqueCategories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (value) {
          formData.selectedCategory = value;
        },
      );
    }

    // Otherwise, fetch categories from the database
    return FutureBuilder<List<String>>(
      future: ref.read(deckStateProvider.notifier).getDeckCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Create a Set to ensure unique values
          final uniqueCategories = snapshot.data!.toSet().toList();

          // If selectedCategory is null or not in the list, set it to the first item
          if (formData.selectedCategory == null ||
              !uniqueCategories.contains(formData.selectedCategory)) {
            formData.selectedCategory = uniqueCategories.first;
          }

          return DropdownButtonFormField<String>(
            borderRadius: BorderRadius.circular(10),
            value: formData.selectedCategory,
            isDense: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Category *',
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: uniqueCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (value) {
              formData.selectedCategory = value;
            },
          );
        }

        // If we have no data, show an error
        return const SizedBox(
          height: 48,
          child: Center(
            child: Text(
              "No categories available",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyDropdown(WidgetRef ref) {
    // If difficulties are passed directly, use them
    if (difficulties != null && difficulties!.isNotEmpty) {
      // Create a Set to ensure unique values
      final uniqueDifficulties = difficulties!.toSet().toList();

      // Ensure selectedDifficulty is valid
      if (formData.selectedDifficulty == null ||
          !uniqueDifficulties.contains(formData.selectedDifficulty)) {
        // Set it to the first item in the list
        formData.selectedDifficulty = uniqueDifficulties.first;
      }

      return DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(10),
        value: formData.selectedDifficulty,
        isDense: true,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Difficulty Level *',
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: uniqueDifficulties.map((difficulty) {
          return DropdownMenuItem(
            value: difficulty,
            child: Text(
              difficulty,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (value) {
          formData.selectedDifficulty = value;
        },
      );
    }

    // Otherwise, fetch difficulties from the database
    return FutureBuilder<List<String>>(
      future: ref.read(deckStateProvider.notifier).getDeckDifficulty(
          ref.watch(userStateProvider).subscriptionPlanID ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Create a Set to ensure unique values
          final uniqueDifficulties = snapshot.data!.toSet().toList();

          // If selectedDifficulty is null or not in the list, set it to the first item
          if (formData.selectedDifficulty == null ||
              !uniqueDifficulties.contains(formData.selectedDifficulty)) {
            formData.selectedDifficulty = uniqueDifficulties.first;
          }

          return DropdownButtonFormField<String>(
            borderRadius: BorderRadius.circular(10),
            value: formData.selectedDifficulty,
            isDense: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Difficulty Level *',
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: uniqueDifficulties.map((difficulty) {
              return DropdownMenuItem(
                value: difficulty,
                child: Text(
                  difficulty,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (value) {
              formData.selectedDifficulty = value;
            },
          );
        }

        // If we have no data, show an error
        return const SizedBox(
          height: 48,
          child: Center(
            child: Text(
              "No difficulty levels available",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardCountField() {
    return TextField(
      controller: formData.cardCountController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Number of Cards *',
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
