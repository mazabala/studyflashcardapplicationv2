import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';

class DeckManagementPage extends ConsumerWidget {
  const DeckManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(deckStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Management',
            style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Column(
        children: [
          const DeckActions(),
          if (deckState.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                deckState.error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (deckState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            const Expanded(child: DeckListView()),
        ],
      ),
    );
  }
}

class DeckActions extends ConsumerWidget {
  const DeckActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _navigateTo(context, const CreateDeckPage()),
            child: const Text('Create Deck'),
          ),
          ElevatedButton(
            onPressed: () => _navigateTo(context, AddCategoryPage()),
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class DeckListView extends ConsumerWidget {
  const DeckListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(deckStateProvider);
    final decks = deckState.decks;

    if (decks.isEmpty) {
      return const Center(child: Text('No decks available'));
    }

    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return ListTile(
          title:
              Text(deck.title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            'Difficulty: ${deck.difficultyLevel} • Category: ${deck.categoryid}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref, deck),
          ),
          onTap: () => _navigateTo(context, DeckDetailsView(deck: deck)),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete ${deck.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(deckStateProvider.notifier).deleteDeck(deck.id);
                if (!context.mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('${deck.title} deleted')),
                );
              } catch (e) {
                if (!context.mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error deleting deck: $e')),
                );
              }
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class DeckDetailsView extends ConsumerStatefulWidget {
  final Deck deck;

  DeckDetailsView({super.key, required this.deck});

  @override
  _DeckDetailsViewState createState() => _DeckDetailsViewState();
}

class _DeckDetailsViewState extends ConsumerState<DeckDetailsView> {
  late TextEditingController _titleController;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.deck.title);
    _selectedDifficulty = widget.deck.difficultyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.deck.title}',
            style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Deck Title'),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: ref
                  .read(deckStateProvider.notifier)
                  .getDeckDifficulty(widget.deck.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration:
                        const InputDecoration(labelText: 'Difficulty Level'),
                    items: snapshot.data!.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDifficulty = value);
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                try {
                  await ref.read(deckStateProvider.notifier).updateDeck(
                        widget.deck.id,
                        _titleController.text,
                        _selectedDifficulty ?? widget.deck.difficultyLevel,
                      );
                  if (!context.mounted) return;
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Deck updated successfully')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error updating deck: $e')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class CreateDeckPage extends ConsumerStatefulWidget {
  const CreateDeckPage({super.key});

  @override
  _CreateDeckPageState createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends ConsumerState<CreateDeckPage> {
  final List<DeckFormData> _deckForms = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Start with one deck form
    _deckForms.add(DeckFormData());
  }

  @override
  void dispose() {
    for (var form in _deckForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _addNewDeckForm() {
    setState(() {
      _deckForms.add(DeckFormData());
    });
  }

  void _removeDeckForm(int index) {
    if (_deckForms.length > 1) {
      setState(() {
        _deckForms[index].dispose();
        _deckForms.removeAt(index);
      });
    }
  }

  Future<void> _createDecks() async {
    if (_isCreating) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Validate all forms
    bool allValid = _deckForms.every((form) => form.isValid());
    if (!allValid) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields in all decks')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final userId = ref.watch(userStateProvider).userId;
      if (userId == null) throw Exception('User not logged in');

      // Create each deck sequentially
      for (var form in _deckForms) {
        await ref.read(deckStateProvider.notifier).createDeck(
              form.topicController.text,
              form.focusController.text,
              form.selectedCategory!,
              form.selectedDifficulty!,
              userId,
              int.parse(form.cardCountController.text),
            );
      }

      if (!context.mounted) return;
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${_deckForms.length} deck(s) created successfully'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error creating decks: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Create Decks', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _deckForms.length,
                itemBuilder: (context, index) {
                  return DeckFormCard(
                    formData: _deckForms[index],
                    index: index,
                    canDelete: _deckForms.length > 1,
                    onDelete: () => _removeDeckForm(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _addNewDeckForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Deck'),
                ),
                ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createDecks,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isCreating ? 'Creating...' : 'Create All Decks'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddCategoryPage extends ConsumerStatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Add Category', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                try {
                  await ref
                      .read(deckStateProvider.notifier)
                      .addDeckCategory(_categoryController.text);
                  if (!context.mounted) return;
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                        content: Text('Category added successfully')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error adding category: $e')),
                  );
                }
              },
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
