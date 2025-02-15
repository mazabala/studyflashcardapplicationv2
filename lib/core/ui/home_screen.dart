import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Track screen view in the next frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureScreenView();
    });
  }

  void _captureScreenView() {
    ref.read(analyticsProvider.notifier).trackScreenView('HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return CustomScaffold(
      currentRoute: currentRoute,
      useScroll: false,
      showBottomNav: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;
              
              // Calculate responsive dimensions
              final titleSize = maxHeight * (isSmallScreen ? 0.08 : 0.1);
              final illustrationHeight = maxHeight * (isSmallScreen ? 0.3 : 0.35);
              final buttonHeight = maxHeight * (isSmallScreen ? 0.07 : 0.08);
              final featureIconSize = maxHeight * 0.025;
              final horizontalPadding = maxWidth * 0.06;
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: maxHeight * 0.05),
                    // Title Section
                    Text(
                      'Deck\nFocus',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontSize: titleSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: maxHeight * 0.03),
                    // Character and Cards Illustration
                    SizedBox(
                      height: illustrationHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Character (centered)
                          Positioned(
                            left: maxWidth * 0.15,
                            child: Container(
                              width: maxWidth * 0.25,
                              height: maxHeight * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(maxWidth * 0.04),
                              ),
                              child: Icon(Icons.person, size: maxWidth * 0.15),
                            ),
                          ),
                          // Floating cards
                          ...List.generate(5, (index) {
                            final top = illustrationHeight * (0.1 + (index * 0.15));
                            final right = maxWidth * (0.05 + (index * 0.08));
                            return Positioned(
                              top: top,
                              right: right,
                              child: Transform.rotate(
                                angle: (index * 0.2) - 0.4,
                                child: Container(
                                  width: maxWidth * 0.2,
                                  height: maxHeight * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(maxWidth * 0.02),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: maxWidth * 0.02,
                                        offset: Offset(0, maxWidth * 0.01),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: maxHeight * 0.03),
                    // Features Section
                    Container(
                      padding: EdgeInsets.all(maxWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(maxWidth * 0.04),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, 
                                color: Colors.blue, 
                                size: featureIconSize
                              ),
                              SizedBox(width: maxWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'AI-powered flashcards for better learning',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: maxHeight * 0.018,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: maxHeight * 0.015),
                          Row(
                            children: [
                              Icon(Icons.school, 
                                color: Colors.blue, 
                                size: featureIconSize
                              ),
                              SizedBox(width: maxWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'Transform your study experience today',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: maxHeight * 0.018,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: maxHeight * 0.03),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(maxWidth * 0.03),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: maxHeight * 0.024,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: maxHeight * 0.05),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}