import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';

class DeckFormData {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController cardCountController;
  String? selectedCategory;
  String? selectedDifficulty;

  DeckFormData()
      : titleController = TextEditingController(),
        descriptionController = TextEditingController(),
        cardCountController = TextEditingController(text: '10');

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    cardCountController.dispose();
  }

  bool isValid() {
    return titleController.text.isNotEmpty &&
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

  const DeckFormCard({
    super.key,
    required this.formData,
    required this.index,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(ref),
            const SizedBox(height: 16),
            _buildDifficultyDropdown(ref),
            const SizedBox(height: 16),
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
        Text(
          'Deck ${index + 1}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            color: Colors.red,
          ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: formData.titleController,
      decoration: const InputDecoration(labelText: 'Deck Title *'),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: formData.descriptionController,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
    );
  }

  Widget _buildCategoryDropdown(WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future: ref.read(deckStateProvider.notifier).getDeckCategory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButtonFormField<String>(
            value: formData.selectedCategory,
            decoration: const InputDecoration(labelText: 'Category *'),
            items: snapshot.data!.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              formData.selectedCategory = value;
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildDifficultyDropdown(WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future: ref.read(deckStateProvider.notifier).getDeckDifficulty(
          ref.watch(userStateProvider).subscriptionPlanID ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButtonFormField<String>(
            value: formData.selectedDifficulty,
            decoration: const InputDecoration(labelText: 'Difficulty Level *'),
            items: snapshot.data!.map((difficulty) {
              return DropdownMenuItem(
                value: difficulty,
                child: Text(difficulty),
              );
            }).toList(),
            onChanged: (value) {
              formData.selectedDifficulty = value;
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildCardCountField() {
    return TextField(
      controller: formData.cardCountController,
      decoration: const InputDecoration(labelText: 'Number of Cards *'),
      keyboardType: TextInputType.number,
    );
  }
}
