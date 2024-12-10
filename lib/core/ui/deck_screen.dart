import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';

class FlashcardPreviewScreen extends StatefulWidget {
  const FlashcardPreviewScreen({super.key});

  @override
  State<FlashcardPreviewScreen> createState() => _FlashcardPreviewState();
}

class _FlashcardPreviewState extends State<FlashcardPreviewScreen> {
  bool isFlipped = false;
  int currentDeckIndex = 0;

  final List<Map<String, dynamic>> previewDecks = [
    {
      'title': 'USMLE Step 1: Cardiovascular System',
      'difficulty': 'High USMLE',
      'cardCount': 60,
      'category': 'Medical Board Exam',
      'previewCard': {
        'front': '''A 58-year-old man presents to the emergency department with a 2-hour history of crushing chest pain radiating to his left arm.
        He has a history of hypertension and hyperlipidemia. On examination, he is diaphoretic and in moderate distress.
        His blood pressure is 160/100 mmHg, and heart rate is 100 bpm. An ECG shows ST-segment elevations in leads II, III, and aVFs.\n\n''' 
        
        'Which of the following is the most likely diagnosis?\n \n'

           ' A) Acute pericarditis\n'
           ' B) Non-ST elevation myocardial infarction (NSTEMI)\n'
           ' C) Acute inferior wall myocardial infarction\n'
           ' D) Stable angina\n'
           ' E) Aortic dissection\n',
        'back': 'Correct Answer: \n C) Acute inferior wall myocardial infarction\n \n'

                  'Explanation:\n'
                  'ST-segment elevations in leads II, III, and aVF suggest an inferior wall myocardial infarction (MI), typically involving the right coronary artery.)\n'
                  'The patient’s symptoms, along with risk factors like hypertension and hyperlipidemia, support this diagnosis. NSTEMI would present without ST elevations. )\n'
                  'Acute pericarditis would show diffuse ST elevations, and aortic dissection typically presents with tearing chest pain radiating to the back.)\n'
      }
    },
    {
      'title': 'USMLE Step 1: Endocrinology',
      'difficulty': 'High USMLE',
      'cardCount': 60,
      'category': 'Medical Board Exam',
      'previewCard': {
        'front': 'A 35-year-old woman presents with fatigue, weight gain, and constipation. '
        'She also reports feeling cold all the time. On examination, her skin is dry, and her reflexes are delayed.\n\n'
        ' Laboratory tests reveal: \n'
        '- TSH: 15 mIU/L (normal 0.4-4.0 mIU/L\n'
        '- Free T4: 0.6 ng/dL (normal 0.8-1.8 ng/dL\n\n'
        
        'Which of the following is the most likely cause of her symptoms? \n\n'
              'A) Graves’ disease\n'
              'B) Hashimoto’s thyroiditis\n'
              'C) Pituitary adenoma\n'
              'D) Iodine toxicity\n'
              'E) Subclinical hypothyroidism\n',
        'back': 'Correct Answer:\n B) Hashimoto’s thyroiditis \n \n'

            'Explanation:\n'
            'The patient presents with classic symptoms of hypothyroidism (fatigue, weight gain, cold intolerance, dry skin). \n'
            'The elevated TSH and low free T4 indicate primary hypothyroidism. Hashimoto’s thyroiditis, an autoimmune condition, is the most common cause of primary hypothyroidism. \n'
            'Graves'' disease causes hyperthyroidism. \n'
            'Subclinical hypothyroidism would have normal free T4 levels.',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentDeck = previewDecks[currentDeckIndex];
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Breakpoints
    const tabletBreakpoint = 768.0;
    const desktopBreakpoint = 1024.0;
    
    return CustomScaffold(
      currentRoute: '/preview',
      useScroll: false, // We'll handle scrolling within our layout
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine layout based on screen width
          if (constraints.maxWidth >= desktopBreakpoint) {
            return _buildDesktopLayout(theme, currentDeck, constraints);
          } else if (constraints.maxWidth >= tabletBreakpoint) {
            return _buildTabletLayout(theme, currentDeck, constraints);
          } else {
            return _buildMobileLayout(theme, currentDeck, constraints);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, Map<String, dynamic> currentDeck, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side Content
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildFeaturesList(theme),
            ),
          ),
        ),
        
        // Right Side Flashcard
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Padding(
            
            padding: const EdgeInsets.all(24.0),
            child: Flashcard_Display_new(theme, currentDeck),
          )
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme, Map<String, dynamic> currentDeck, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFeaturesList(theme),
            ),
          ),
        ),
        
        // Right Side Flashcard
        Expanded(
          child: Container(
            height: constraints.maxHeight,
            padding: const EdgeInsets.all(16.0),
            child: Flashcard_Display_new(theme, currentDeck),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme, Map<String, dynamic> currentDeck, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Flashcard Section
          SingleChildScrollView(
            child: Padding(
           
            padding: const EdgeInsets.all(16.0),
            child: Flashcard_Display_new(theme, currentDeck),
          ),),
          
          // Features Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFeaturesList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'What Makes FlashCard Study Pro Unique?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildFeatureSection(
          '1. Customizable Flashcards',
          'Create, edit, and manage flashcards tailored to your study needs. Each card can include text, images, and explanations for more engaging learning.',
          Icons.edit,
          theme,
        ),
        _buildFeatureSection(
          '2. Smart Deck Organization',
          'Group flashcards into decks by subjects or categories. Track your progress and prioritize challenging topics with dynamic difficulty tagging.',
          Icons.folder_special,
          theme,
        ),
        _buildFeatureSection(
          '3. Interactive Study Modes',
          'Switch between multiple study modes including Preview Mode, Flip Mode, and Quiz Mode for comprehensive learning.',
          Icons.switch_access_shortcut,
          theme,
        ),
        _buildFeatureSection(
          '4. Progress Tracking & Insights',
          'Monitor your performance with detailed insights on cards reviewed, mastery level, and areas needing focus.',
          Icons.insights,
          theme,
        ),
        _buildFeatureSection(
          '5. Seamless Navigation',
          'Easily switch between decks and cards with intuitive navigation controls. Swipe, tap, or use buttons to move through content without breaking focus.',
          Icons.swipe,
          theme,
        ),
        const SizedBox(height: 32),
        Center(
          child: _buildCTAButton(theme),
        ),
      ],
    );
  }

  Widget _buildFeatureSection(String title, String description, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: theme.colorScheme.primary,
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Text(
        'Sign Up for Demo',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

Widget Flashcard_Display_new(ThemeData theme, Map<String, dynamic> currentDeck) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // This ensures the card takes minimum required height
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Deck Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDeck['title'],
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      currentDeck['category'],
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentDeck['difficulty'],
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentDeck['cardCount']} cards',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Flashcard Content
        GestureDetector(
          onTap: () {
            setState(() {
              isFlipped = !isFlipped;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFlipped
                  ? theme.colorScheme.secondary.withOpacity(0.1)
                  : Colors.white,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isFlipped
                    ? currentDeck['previewCard']['back']
                    : currentDeck['previewCard']['front'],
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),

        // Navigation Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentDeckIndex = (currentDeckIndex - 1 + previewDecks.length) % previewDecks.length;
                    isFlipped = false;
                  });
                },
                child: const Text('Previous Deck'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentDeckIndex = (currentDeckIndex + 1) % previewDecks.length;
                    isFlipped = false;
                  });
                },
                child: const Text('Next Deck'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
