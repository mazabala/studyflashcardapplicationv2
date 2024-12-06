import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final theme = Theme.of(context);

    return CustomScaffold(
      currentRoute: currentRoute,
      useScroll: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
              child: isDesktop 
                ? _buildDesktopLayout(context, theme,constraints)
                : isTablet 
                  ? _buildTabletLayout(context, theme,constraints)
                  : _buildMobileLayout(context, theme,constraints),
            ),
          );
        },
      ),
    );
  }

 Widget _buildDesktopLayout(BuildContext context, ThemeData theme, BoxConstraints constraints) {
    return Column(
      children: [
        _buildHeroSection(theme, constraints),
        const SizedBox(height: 48),
        _buildFeatureGrid(theme, constraints),
        const SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildHowItWorks(theme),
            ),
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildPopularDecks(theme),
                  const SizedBox(height: 32),
                  _buildStatistics(theme),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildCallToAction(context, theme),
      ],
    );
  }

 Widget _buildTabletLayout(BuildContext context, ThemeData theme, BoxConstraints constraints) {
    return Column(
      children: [
        _buildHeroSection(theme, constraints),
        const SizedBox(height: 32),
        _buildFeatureGrid(theme, constraints),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildHowItWorks(theme),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: [
                  _buildPopularDecks(theme),
                  const SizedBox(height: 24),
                  _buildStatistics(theme),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildCallToAction(context, theme),
      ],
    );
  }

 Widget _buildMobileLayout(BuildContext context, ThemeData theme, BoxConstraints constraints) {
    return Column(
      children: [
        _buildHeroSection(theme, constraints),
        const SizedBox(height: 24),
        _buildFeatureGrid(theme, constraints),
        const SizedBox(height: 24),
        _buildHowItWorks(theme),
        const SizedBox(height: 24),
        _buildPopularDecks(theme),
        const SizedBox(height: 24),
        _buildStatistics(theme),
        const SizedBox(height: 24),
        _buildCallToAction(context, theme),
      ],
    );
  }

  Widget _buildHeroImage(BoxConstraints constraints) {
    final imageHeight = constraints.maxWidth < 800 ? 200.0 : 300.0;
    
    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Hero Image'),
      ),
    );
  }
  Widget _buildHeroText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Flashcard Study Hub!',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Maximize your learning potential with AI-powered flashcards. Transform your study experience today.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
  Widget _buildHeroSection(ThemeData theme, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 800;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          if (isSmallScreen) ...[
            _buildHeroText(theme),
            const SizedBox(height: 24),
            _buildHeroImage(constraints),
          ] else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildHeroText(theme),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildHeroImage(constraints),
                ),
              ],
            ),
        ],
      ),
    );
  }
Widget _buildFeatureCard(Map<String, dynamic> feature, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            feature['icon'] as IconData,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          feature['title'] as String,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          feature['description'] as String,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
 Widget _buildFeatureGrid(ThemeData theme, BoxConstraints constraints) {
    final crossAxisCount = _getFeatureGridCrossAxisCount(constraints.maxWidth);
    final childAspectRatio = _getFeatureGridChildAspectRatio(constraints.maxWidth);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: _buildFeatureCards(theme),
    );
  }

  int _getFeatureGridCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 2;
    return 1;
  }

  double _getFeatureGridChildAspectRatio(double width) {
    if (width >= 1200) return 1.5;
    if (width >= 800) return 1.3;
    return 1.2;
  }
List<Widget> _buildFeatureCards(ThemeData theme) {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'AI-Powered',
        'description': 'Smart recommendations and personalized learning paths',
      },
      {
        'icon': Icons.speed,
        'title': 'Learn Faster',
        'description': 'Optimized study intervals based on your performance',
      },
      {
        'icon': Icons.devices,
        'title': 'Study Anywhere',
        'description': 'Seamless synchronization across all your devices',
      },
      {
        'icon': Icons.analytics,
        'title': 'Track Progress',
        'description': 'Detailed analytics and progress monitoring',
      },
    ];

    return features.map((feature) => _buildFeatureCard(feature, theme)).toList();
  }

  Widget _buildHowItWorks(ThemeData theme) {
    final steps = [
      {
        'icon': Icons.library_books,
        'text': "Create or Browse Decks: Choose from a wide range of pre-generated decks or create your own.",
      },
      {
        'icon': Icons.schedule,
        'text': "Study at Your Own Pace: Review your flashcards anytime, anywhere.",
      },
      {
        'icon': Icons.insights,
        'text': "Track Your Progress: Stay motivated with in-depth progress tracking.",
      },
      {
        'icon': Icons.psychology,
        'text': "AI-Enhanced Learning: Personalized study recommendations.",
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works:',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FeatureItem(
              icon: step['icon'] as IconData,
              text: step['text'] as String,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPopularDecks(ThemeData theme) {
    final decks = [
      {'icon': Icons.history_edu, 'text': "History of Ancient Civilizations"},
      {'icon': Icons.translate, 'text': "Spanish Vocabulary Builder"},
      {'icon': Icons.science, 'text': "Physics: Key Concepts and Formulas"},
      {'icon': Icons.calculate, 'text': "Math: Algebra and Geometry Essentials"},
      {'icon': Icons.medical_services, 'text': "Medical Terminology"},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Decks:',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          ...decks.map((deck) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FeatureItem(
              icon: deck['icon'] as IconData,
              text: deck['text'] as String,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildStatItem(theme, '10K+', 'Active Users'),
          const SizedBox(height: 16),
          _buildStatItem(theme, '500+', 'Study Decks'),
          const SizedBox(height: 16),
          _buildStatItem(theme, '1M+', 'Cards Studied'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Transform Your Study Experience?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to deck screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Start Studying Now",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}