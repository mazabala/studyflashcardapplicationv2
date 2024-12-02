// lib/core/ui/widgets/deck/system_deck_dialog.dart

import 'package:flutter/material.dart';

class CategoryMultiSelect extends StatefulWidget {
  final List<String> categories;
  final Set<String> selectedCategories;
  final ValueChanged<Set<String>> onSelectionChanged;
  final Function(String) onAddCategory;

  const CategoryMultiSelect({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.onSelectionChanged,
    required this.onAddCategory,
  }) : super(key: key);

  @override
  _CategoryMultiSelectState createState() => _CategoryMultiSelectState();
}

class _CategoryMultiSelectState extends State<CategoryMultiSelect> {
  // Toggles the selection and updates the parent widget.
  void _toggleCategory(String category, bool selected) {
    setState(() {
      if (selected) {
        widget.selectedCategories.add(category);
      } else {
        widget.selectedCategories.remove(category);
      }
    });
    widget.onSelectionChanged(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              widget.selectedCategories.isEmpty
                  ? 'Select Categories'
                  : '${widget.selectedCategories.length} selected',
            ),
            children: [
              ...widget.categories.map((category) => CheckboxListTile(
                    title: Text(category),
                    value: widget.selectedCategories.contains(category),
                    onChanged: (bool? value) =>
                        _toggleCategory(category, value ?? false),
                    dense: true,
                  )),
              // Add new category input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Add new category',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: widget.onAddCategory,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Input handled on submit
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DescriptionFields extends StatelessWidget {
  final Set<String> selectedCategories;
  final Map<String, TextEditingController> descriptionControllers;

  const DescriptionFields({
    Key? key,
    required this.selectedCategories,
    required this.descriptionControllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCategories.isNotEmpty) ...[
          const Text(
            'Descriptions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...selectedCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: descriptionControllers[category] ??
                    TextEditingController(),
                decoration: InputDecoration(
                  labelText: category,
                  hintText: 'Enter description for $category',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}



class SystemDeckDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> difficulties;
  final List<String> selectedCategories;
  final String? selectedDifficulty;
  final TextEditingController cardCountController;
  final Map<String, TextEditingController> descriptionControllers;
  final Function(String) onCategoryToggle;
  final Function(String) onAddCategory;
  final Function(String) onDifficultyChanged;
  final VoidCallback onConfirm;

  const SystemDeckDialog({
    Key? key,
    required this.categories,
    required this.difficulties,
    required this.selectedCategories,
    required this.selectedDifficulty,
    required this.cardCountController,
    required this.descriptionControllers,
    required this.onCategoryToggle,
    required this.onAddCategory,
    required this.onDifficultyChanged,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _SystemDeckDialogState createState() => _SystemDeckDialogState();
}

class _SystemDeckDialogState extends State<SystemDeckDialog> {
  late List<String> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  void _toggleCategory(String category) {
    setState(() {
       widget.onCategoryToggle(category);
    });
   
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create System Deck',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Categories Multi-Select
              const Text(
                'Categories',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text(widget.selectedCategories.isEmpty
                    ? 'Select Categories'
                    : '${widget.selectedCategories.length} selected'),
                children: [
                  ..._filteredCategories.map(
                    (category) => CheckboxListTile(
                      title: Text(category),
                      value: widget.selectedCategories.contains(category),
                      onChanged: (bool? value) {
                        _toggleCategory(category);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Add new category',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: widget.onAddCategory,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                            const SizedBox(height: 16),
              // Description Fields for Selected Categories
              if (widget.selectedCategories.isNotEmpty) ...[
                const Text(
                  'Descriptions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.selectedCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: widget.descriptionControllers[category] ??
                          TextEditingController(),
                      decoration: InputDecoration(
                        labelText: 'Description for $category',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  );
                }).toList(),
              ],
              const SizedBox(height: 16),
              // Difficulty Selection
              const Text(
                'Difficulty',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: widget.selectedDifficulty,
                hint: const Text('Select Difficulty'),
                isExpanded: true,
                items: widget.difficulties.map((difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Text(difficulty),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onDifficultyChanged(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Card Count Input
              TextField(
                controller: widget.cardCountController,
                decoration: const InputDecoration(
                  labelText: 'Card Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              // Confirm Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  child: const Text('Create Deck'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
