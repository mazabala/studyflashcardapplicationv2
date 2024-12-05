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
        'front': 'A 58-year-old man presents to the emergency department with a 2-hour history of crushing chest pain radiating to his left arm.' 
        'He has a history of hypertension and hyperlipidemia. On examination, he is diaphoretic and in moderate distress. '
        'His blood pressure is 160/100 mmHg, and heart rate is 100 bpm. An ECG shows ST-segment elevations in leads II, III, and aVF.\n' 
        'Which of the following is the most likely diagnosis?\n \n'

           ' A) Acute pericarditis\n'
           ' B) Non-ST elevation myocardial infarction (NSTEMI)\n'
           ' C) Acute inferior wall myocardial infarction)\n'
           ' D) Stable angina)\n'
           ' E) Aortic dissection)\n',
        'back': 'Correct Answer: \n C) Acute inferior wall myocardial infarction)\n \n'

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
        'She also reports feeling cold all the time. On examination, her skin is dry, and her reflexes are delayed.'
        ' Laboratory tests reveal: \n'
        '- TSH: 15 mIU/L (normal 0.4-4.0 mIU/L)'
        '- Free T4: 0.6 ng/dL (normal 0.8-1.8 ng/dL)\n'
        'Which of the following is the most likely cause of her symptoms? \n'
              'A) Graves’ disease\n'
              'B) Hashimoto’s thyroiditis\n'
              'C) Pituitary adenoma\n'
              'D) Iodine toxicity\n'
              'E) Subclinical hypothyroidism\n',
        'back': 'Correct Answer: B) Hashimoto’s thyroiditis \n \n'

            'Explanation:'
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

    return CustomScaffold(
      currentRoute: '/preview',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.9,
              ),
              child: 
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicHeight(
                  child: Column(
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

                      // Flashcard Preview (dynamic height)
                      Expanded(
                        child: GestureDetector(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
