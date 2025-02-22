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
        focusController.text.isNotEmpty &&
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
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const Divider(height: 32),
                  _buildTopicField(),
                  const SizedBox(height: 24),
                  _buildFocusField(),
                  const SizedBox(height: 24),
                  _buildCategoryDropdown(ref),
                  const SizedBox(height: 24),
                  _buildDifficultyDropdown(ref),
                  const SizedBox(height: 24),
                  _buildCardCountField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deck ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the deck details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              style: IconButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: formData.topicController,
        decoration: InputDecoration(
          labelText: 'Topic *',
          hintText: 'Main subject ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.subject),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFocusField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: formData.focusController,
        decoration: InputDecoration(
          labelText: 'Focus/Concept *',
          hintText: 'Specific area ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.lightbulb_outline),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<List<String>>(
        future: ref.read(deckStateProvider.notifier).getDeckCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(
              value: formData.selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Category *',
                hintText: 'Select a category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category_outlined),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyDropdown(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<List<String>>(
        future: ref.read(deckStateProvider.notifier).getDeckDifficulty(
            ref.watch(userStateProvider).subscriptionPlanID ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(
              value: formData.selectedDifficulty,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Difficulty Level *',
                hintText: 'Select difficulty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.trending_up),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardCountField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: formData.cardCountController,
        decoration: InputDecoration(
          labelText: 'Number of Cards *',
          hintText: 'How many cards to generate',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.style),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
