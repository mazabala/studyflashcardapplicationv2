import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/presentation/screens/study/study_screen_controller.dart';

import 'package:flashcardstudyapplication/presentation/widgets/common/CustomButton.dart';
import 'package:flashcardstudyapplication/presentation/widgets/common/CustomScaffold.dart';
import 'package:flashcardstudyapplication/presentation/widgets/common/navigation_button.dart';
import 'package:flashcardstudyapplication/presentation/widgets/study/flashcard_display.dart';
import 'package:flashcardstudyapplication/presentation/widgets/study/progress_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';

import 'package:flashcardstudyapplication/presentation/widgets/common/progress_indicator.dart';

import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';
import 'dart:math';

class StudyScreen extends ConsumerStatefulWidget {
  final Deck deck;
  final Collection? collection;
  final bool isCollectionStudy;
  final List<Deck>? remainingDecks;

  const StudyScreen({
    Key? key,
    required this.deck,
    this.collection,
    this.isCollectionStudy = false,
    this.remainingDecks,
  }) : super(key: key);

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  late StudyScreenController _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  late final FlashcardNotifier _flashcardNotifier;

  @override
  void initState() {
    super.initState();
    _flashcardNotifier = ref.read(flashcardStateProvider.notifier);
    _initializeController();
    _trackScreenView();

    // Track analytics for collection study flow
    if (widget.isCollectionStudy && widget.collection != null) {
      ref.read(analyticsProvider.notifier).trackEvent(
        'collection_study_deck_started',
        properties: {
          'collection_id': widget.collection!.id,
          'collection_name': widget.collection!.name,
          'deck_id': widget.deck.id,
          'deck_title': widget.deck.title,
          'remaining_decks': widget.remainingDecks?.length ?? 0,
        },
      );
    }
  }

  Future<void> _initializeController() async {
    try {
      _controller = StudyScreenController(
        ref: ref,
        deckId: widget.deck.id,
        isCollectionStudy: widget.isCollectionStudy,
        onFinish: () {
          if (!_isDisposed) {
            // Clean up state before navigation
            _flashcardNotifier.endSession();

            // If this is part of a collection study and there are remaining decks
            if (widget.isCollectionStudy &&
                widget.remainingDecks != null &&
                widget.remainingDecks!.isNotEmpty) {
              _moveToNextDeck();
            } else {
              // Navigate in the next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/myDecks');
                }
              });
            }
          }
        },
      );
      await _flashcardNotifier.getFlashcardsForDeck(widget.deck.id);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing study session: $e')),
        );
      }
    }
  }

  void _moveToNextDeck() {
    if (!widget.isCollectionStudy ||
        widget.remainingDecks == null ||
        widget.remainingDecks!.isEmpty) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading next deck...'),
            ],
          ),
        );
      },
    );

    // Get the next deck
    final nextDeck = widget.remainingDecks!.first;
    final remainingDecks = widget.remainingDecks!.skip(1).toList();

    // Preload the next deck's flashcards
    ref
        .read(flashcardStateProvider.notifier)
        .getFlashcardsForDeck(nextDeck.id)
        .then((_) {
      // Navigate to the next deck
      if (mounted) {
        // Dismiss the loading dialog
        Navigator.of(context).pop();

        // Use pushReplacement to replace the current screen with the next deck
        // This prevents going back to the previous deck
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                StudyScreen(
              deck: nextDeck,
              collection: widget.collection,
              isCollectionStudy: true,
              remainingDecks: remainingDecks,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Use a fade transition for smoother experience
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }).catchError((error) {
      // Handle error
      if (mounted) {
        // Dismiss the loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading next deck: $error')),
        );
      }
    });
  }

  void _trackScreenView() {
    if (!mounted) return;
    ref.read(analyticsProvider.notifier).trackScreenView('StudyScreen');
    ref.read(analyticsProvider.notifier).trackEvent(
      'study_session_started',
      properties: {
        'deck_id': widget.deck.id,
        'deck_title': widget.deck.title,
        'is_collection_study': widget.isCollectionStudy,
        'collection_id': widget.collection?.id ?? 'none',
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clean up state synchronously before disposal
    if (_isInitialized) {
      _flashcardNotifier.endSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final flashcardState = ref.watch(flashcardStateProvider);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    if (!_isInitialized) {
      return CustomScaffold(
        currentRoute: currentRoute,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (flashcardState.error.isNotEmpty) {
      return CustomScaffold(
        currentRoute: currentRoute,
        showBottomNav: false,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${flashcardState.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Return to Decks',
                isLoading: false,
                icon: Icons.arrow_back,
                onPressed: () {
                  // Clean up state before navigation
                  if (!_isDisposed) {
                    _flashcardNotifier.endSession();
                  }
                  Navigator.pushReplacementNamed(context, '/myDecks');
                },
              ),
            ],
          ),
        ),
      );
    }

    return CustomScaffold(
      currentRoute: currentRoute,
      showBottomNav: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Collection info (if studying as part of a collection)
                  if (widget.isCollectionStudy && widget.collection != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Collection: ${widget.collection!.name}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),

                  // Top Section with fixed height
                  SizedBox(
                    height: 40,
                    child: ProgressIndicatorWidget(deckId: widget.deck.id),
                  ),
                  const SizedBox(height: 16),

                  // Middle Section (Flashcard)
                  SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? constraints.maxWidth : 800,
                        minHeight: 200,
                        maxHeight: min(500, constraints.maxHeight * 0.6),
                      ),
                      child: FlashcardDisplay(
                        widget.deck.title,
                        widget.deck.description,
                        widget.deck.difficultyLevel,
                        deckId: widget.deck.id,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Section (Buttons)
                  Container(
                    width: isSmallScreen ? constraints.maxWidth : 600,
                    child: !flashcardState.isFlipped
                        ? NavigationButtonsWidget(controller: _controller)
                        : ProgressButtonWidget(controller: _controller),
                  ),

                  const SizedBox(height: 16),

                  // Back Button
                  SizedBox(
                    width: isSmallScreen ? constraints.maxWidth : 200,
                    child: CustomButton(
                      text: widget.isCollectionStudy
                          ? 'Return to Collection'
                          : 'Return to Decks',
                      isLoading: false,
                      icon: Icons.arrow_back,
                      onPressed: () {
                        if (!_isDisposed) {
                          ref.read(analyticsProvider.notifier).trackEvent(
                            'study_session_ended',
                            properties: {
                              'deck_id': widget.deck.id,
                              'cards_reviewed':
                                  flashcardState.currentCardIndex + 1,
                              'is_collection_study': widget.isCollectionStudy,
                            },
                          );
                          _flashcardNotifier.endSession();
                          if (widget.isCollectionStudy &&
                              widget.collection != null) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/myDecks');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
