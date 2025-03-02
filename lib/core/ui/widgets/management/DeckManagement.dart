import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/management/deck_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/utils/file_import_utils.dart';
import 'package:flashcardstudyapplication/core/models/deck_import.dart';
import 'dart:convert';
import 'dart:async';

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
  bool _isLoadingInitialData = true;
  List<String>? _categories;
  List<String>? _difficulties;
  dynamic _collectionInfo; // Can be CollectionInfo or List<CollectionInfo>

  @override
  void initState() {
    super.initState();
    // Start with one empty deck form
    _deckForms.add(DeckFormData());

    // Load categories and difficulties once
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Fetch the data in parallel
      final results = await Future.wait([
        ref.read(deckStateProvider.notifier).getDeckCategory(),
        ref.read(deckStateProvider.notifier).getDeckDifficulty(
            ref.read(userStateProvider).subscriptionPlanID ?? ''),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0];
          _difficulties = results[1];
          _isLoadingInitialData = false;

          // Initialize the first form with default values
          if (_categories != null &&
              _categories!.isNotEmpty &&
              _difficulties != null &&
              _difficulties!.isNotEmpty) {
            _deckForms[0].selectedCategory = _categories!.first;
            _deckForms[0].selectedDifficulty = _difficulties!.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading form data: $e')),
        );
      }
    }
  }

  void _addNewDeckForm() {
    setState(() {
      final newForm = DeckFormData();
      // Pre-select first values to prevent flicker
      if (_categories != null && _categories!.isNotEmpty) {
        newForm.selectedCategory = _categories!.first;
      }
      if (_difficulties != null && _difficulties!.isNotEmpty) {
        newForm.selectedDifficulty = _difficulties!.first;
      }
      _deckForms.add(newForm);
    });

    // Scroll to the bottom after adding a new deck form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_deckForms.length > 2) {
        // Only scroll if we have more than 2 forms to avoid unnecessary scrolling
        final scrollController = PrimaryScrollController.of(context);
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    // Validate all forms
    bool allValid = true;
    for (final form in _deckForms) {
      if (!form.isValid()) {
        allValid = false;
        break;
      }
    }

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields for all decks'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final userState = ref.read(userStateProvider);
      final userId = userState.userId;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Check if we're processing imported collections
      if (_collectionInfo != null) {
        await _processCollectionsInBatches(userId);
      } else {
        // Regular deck creation without collections
        final deckNotifier = ref.read(deckStateProvider.notifier);
        for (final form in _deckForms) {
          await deckNotifier.createDeck(
            form.topicController.text,
            form.focusController.text,
            form.selectedCategory!,
            form.selectedDifficulty!,
            userId,
            int.parse(form.cardCountController.text),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created ${_deckForms.length} decks'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating decks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // Process collections in batches, one collection at a time
  Future<void> _processCollectionsInBatches(String userId) async {
    final deckNotifier = ref.read(deckStateProvider.notifier);
    final collectionService = ref.read(collectionServiceProvider);
    final deckService = ref.read(deckServiceProvider);

    // Get the collections to process
    List<CollectionInfo> collectionsToProcess = [];
    if (_collectionInfo is List<CollectionInfo>) {
      collectionsToProcess = _collectionInfo as List<CollectionInfo>;
    } else if (_collectionInfo is CollectionInfo) {
      collectionsToProcess = [_collectionInfo as CollectionInfo];
    } else {
      throw Exception('Invalid collection information');
    }

    // Calculate total decks for progress tracking
    final totalDecks = collectionsToProcess.fold<int>(
        0, (sum, collection) => sum + collection.decks.length);
    int processedDecks = 0;
    int processedCollections = 0;
    String currentCollectionName =
        collectionsToProcess.isNotEmpty ? collectionsToProcess[0].name : '';
    String currentDeckInfo = '';

    // Track success/failure statistics
    int successfulCollections = 0;
    int failedCollections = 0;
    int successfulDecks = 0;
    int failedDecks = 0;
    List<String> errors = [];

    // Create a stateful dialog that we can update
    final progressDialogCompleter = Completer<void>();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            // Store the setState function to update the dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!progressDialogCompleter.isCompleted) {
                progressDialogCompleter.complete();
              }
            });

            return AlertDialog(
              title: const Text('Processing Collections'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: processedDecks / totalDecks,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing collection ${processedCollections + 1}/${collectionsToProcess.length}: $currentCollectionName',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Decks: $processedDecks/$totalDecks',
                    textAlign: TextAlign.center,
                  ),
                  if (currentDeckInfo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentDeckInfo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ).then((_) {
        // Dialog was closed
        if (!progressDialogCompleter.isCompleted) {
          progressDialogCompleter.complete();
        }
      });
    }

    // Wait for the dialog to be built
    await progressDialogCompleter.future;

    // Function to update the progress dialog
    void updateProgressDialog() {
      if (mounted) {
        // Use setState to rebuild the dialog
        setState(() {
          // This will trigger a rebuild of the current widget
          // which will update the dialog with new values
        });
      }
    }

    try {
      // Process each collection one by one
      for (int collectionIndex = 0;
          collectionIndex < collectionsToProcess.length;
          collectionIndex++) {
        final collection = collectionsToProcess[collectionIndex];
        processedCollections = collectionIndex;
        currentCollectionName = collection.name;
        updateProgressDialog();

        // Create all decks for this collection
        final List<String> createdDeckIds = [];
        bool collectionSuccess = true;

        for (int deckIndex = 0;
            deckIndex < collection.decks.length;
            deckIndex++) {
          final deck = collection.decks[deckIndex];
          currentDeckInfo = '${deck.topic} - ${deck.focus}';
          updateProgressDialog();

          try {
            // Create the deck
            await deckNotifier.createDeck(
              deck.topic,
              deck.focus,
              deck.category,
              deck.difficultyLevel,
              userId,
              deck.cardCount,
            );

            // Get the ID of the created deck
            final userDecks = await deckService.getUserDecks(userId);
            final recentlyCreatedDecks = userDecks
                .where((d) => d.creatorid == userId)
                .toList()
              ..sort((a, b) => b.createdat.compareTo(a.createdat));

            if (recentlyCreatedDecks.isNotEmpty) {
              createdDeckIds.add(recentlyCreatedDecks.first.id);
              successfulDecks++;
            } else {
              // Deck was created but we couldn't get its ID
              failedDecks++;
              errors.add(
                  'Could not retrieve ID for deck: ${deck.topic} - ${deck.focus}');
              collectionSuccess = false;
            }
          } catch (e) {
            // Handle deck creation error
            failedDecks++;
            errors.add(
                'Error creating deck "${deck.topic} - ${deck.focus}": ${e.toString()}');
            collectionSuccess = false;
          }

          // Update progress
          processedDecks++;
          updateProgressDialog();
        }

        // Create the collection with the decks we just created
        if (createdDeckIds.isNotEmpty) {
          try {
            currentDeckInfo = 'Creating collection: ${collection.name}';
            updateProgressDialog();

            await collectionService.createCollection(
              name: collection.name,
              subject: collection.subject,
              description: collection.description,
              deckIds: createdDeckIds,
              isPublic: collection.isPublic,
            );

            currentDeckInfo = 'Collection created: ${collection.name}';
            successfulCollections++;
          } catch (e) {
            // Handle collection creation error
            failedCollections++;
            errors.add(
                'Error creating collection "${collection.name}": ${e.toString()}');
            currentDeckInfo = 'Failed to create collection: ${collection.name}';
          }
          updateProgressDialog();
        } else {
          // No decks were successfully created for this collection
          failedCollections++;
          errors.add(
              'No decks were successfully created for collection: ${collection.name}');
        }
      }
    } catch (e) {
      // Handle unexpected errors
      errors.add('Unexpected error during processing: ${e.toString()}');
    } finally {
      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show completion dialog with statistics
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Complete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processed ${collectionsToProcess.length} collections with $totalDecks total decks.',
                ),
                const SizedBox(height: 8),
                Text(
                  'Successful collections: $successfulCollections',
                  style: TextStyle(
                    color:
                        successfulCollections > 0 ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  'Failed collections: $failedCollections',
                  style: TextStyle(
                    color: failedCollections > 0 ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Successful decks: $successfulDecks',
                  style: TextStyle(
                    color: successfulDecks > 0 ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  'Failed decks: $failedDecks',
                  style: TextStyle(
                    color: failedDecks > 0 ? Colors.red : Colors.grey,
                  ),
                ),
                if (errors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Errors:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 100,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: errors.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '• ${errors[index]}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (errors.length > 5)
                    Text(
                      '... and ${errors.length - 5} more errors',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      // Reset collection info after processing
      _collectionInfo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title:
            Text('Create Decks', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: _isLoadingInitialData
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate number of columns based on available width
                  final double availableWidth = constraints.maxWidth;
                  final int crossAxisCount =
                      (availableWidth / 400).floor().clamp(1, 3);
                  // Increase childAspectRatio to make cards shorter (less tall)
                  final childAspectRatio = crossAxisCount == 1 ? 1.3 : 1.2;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Creating ${_deckForms.length} deck${_deckForms.length > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _showImportDialog,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Import from JSON',
                                      style: TextStyle(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _addNewDeckForm,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Deck',
                                      style: TextStyle(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: GridView.builder(
                            key: ValueKey<int>(_deckForms.length),
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20.0,
                              mainAxisSpacing:
                                  20.0, // Increase spacing for better readability
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: _deckForms.length,
                            itemBuilder: (context, index) {
                              return AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: DeckFormCard(
                                  formData: _deckForms[index],
                                  index: index,
                                  canDelete: _deckForms.length > 1,
                                  onDelete: () => _removeDeckForm(index),
                                  categories: _categories,
                                  difficulties: _difficulties,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isCreating ? null : _createDecks,
                        icon: _isCreating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                            _isCreating ? 'Creating...' : 'Create All Decks',
                            style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    for (var form in _deckForms) {
      form.dispose();
    }
    super.dispose();
  }

  Future<dynamic> _showCollectionSelectionDialog(
      List<CollectionInfo> collections) async {
    return showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Collection'),
        content: SizedBox(
          width: double.maxFinite,
          // Limit the height to prevent the dialog from being too large
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add "Process All Collections" option at the top
              Card(
                color: Colors.green.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.green.withOpacity(0.5)),
                ),
                child: ListTile(
                  title: const Text(
                    'Process All Collections',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${collections.length} collections with ${collections.fold<int>(0, (sum, collection) => sum + collection.decks.length)} total decks',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  leading: Icon(Icons.all_inclusive, color: Colors.green[700]),
                  onTap: () => Navigator.pop(context, collections),
                ),
              ),
              const Divider(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Or select a single collection:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(collection.name),
                        subtitle: Text(
                          '${collection.subject} • ${collection.decks.length} decks',
                        ),
                        leading: Icon(
                          Icons.collections_bookmark,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () => Navigator.pop(context, collection),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog() async {
    try {
      // Show loading indicator
      setState(() {
        _isLoadingInitialData = true;
      });

      // Pick JSON file
      final jsonContent = await FileImportUtils.pickJsonFile();

      // Hide loading indicator
      setState(() {
        _isLoadingInitialData = false;
      });

      if (jsonContent == null) {
        // User cancelled file picking
        return;
      }

      if (!FileImportUtils.isValidJsonStructure(jsonContent)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Invalid JSON format. Please select a valid deck import file.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Parse the JSON content
      try {
        final jsonMap = jsonDecode(jsonContent) as Map<String, dynamic>;
        final deckImport = DeckImport.fromJson(jsonMap);

        // Clear existing deck forms
        setState(() {
          _deckForms.clear();
        });

        // Check if there are any collections
        if (deckImport.collections.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No collections found in the imported file.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show collection selection dialog
        if (!mounted) return;
        final selection =
            await _showCollectionSelectionDialog(deckImport.collections);

        if (selection == null) {
          // User cancelled collection selection
          return;
        }

        // Process the selection (either a single collection or all collections)
        List<CollectionInfo> collectionsToProcess = [];
        if (selection is List<CollectionInfo>) {
          // User selected "Process All Collections"
          collectionsToProcess = selection;
        } else if (selection is CollectionInfo) {
          // User selected a single collection
          collectionsToProcess = [selection];
        } else {
          // Invalid selection type
          return;
        }

        // Create deck forms from the first collection's decks initially
        // We'll process the rest during batch creation
        if (collectionsToProcess.isNotEmpty) {
          final firstCollection = collectionsToProcess[0];
          for (final deck in firstCollection.decks) {
            final formData = DeckFormData();
            formData.topicController.text = deck.topic;
            formData.focusController.text = deck.focus;
            formData.cardCountController.text = deck.cardCount.toString();
            formData.selectedCategory = deck.category;
            formData.selectedDifficulty = deck.difficultyLevel;

            setState(() {
              _deckForms.add(formData);
            });
          }
        }

        // Store collection info for batch processing
        _collectionInfo = collectionsToProcess;

        // Show success message with batch processing info
        if (!mounted) return;
        final totalDecks = collectionsToProcess.fold<int>(
            0, (sum, collection) => sum + collection.decks.length);
        final collectionNames =
            collectionsToProcess.map((c) => '"${c.name}"').join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ready to import ${collectionsToProcess.length} collections with $totalDecks total decks.\n'
                'Collections will be processed in batches.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Update UI to show the first collection's decks
        if (!mounted) return;
        if (collectionsToProcess.length > 1) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Batch Processing'),
              content: Text(
                  'The form now shows decks from the first collection "${collectionsToProcess[0].name}".\n\n'
                  'When you click "Create All Decks", all ${collectionsToProcess.length} collections '
                  'with $totalDecks total decks will be processed in sequence, '
                  'creating one collection at a time.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing JSON: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing decks: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
