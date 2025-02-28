import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
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
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBackgroundColor
                  : theme.colorScheme.primary,
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBackgroundColor.withOpacity(0.8)
                  : theme.colorScheme.primary.withOpacity(0.8),
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
              // Reduce illustration height to prevent overlap
              final illustrationHeight =
                  maxHeight * (isSmallScreen ? 0.25 : 0.3);
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
                    SizedBox(height: maxHeight * 0.02), // Reduced spacing
                    // Character and Cards Illustration
                    Container(
                      height: illustrationHeight,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Character (centered)
                          Positioned(
                            left: maxWidth * 0.15,
                            child: Container(
                              width: maxWidth * 0.25,
                              height: maxHeight * 0.18, // Slightly smaller
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary,
                                borderRadius:
                                    BorderRadius.circular(maxWidth * 0.04),
                              ),
                              child: Icon(Icons.person, size: maxWidth * 0.15),
                            ),
                          ),
                          // Floating cards - limit the number based on screen width
                          ...List.generate(maxWidth < 400 ? 3 : 5, (index) {
                            // Adjust card positioning to prevent overflow
                            final top = illustrationHeight *
                                (0.1 +
                                    (index * 0.12)); // Reduced vertical spread
                            final right = maxWidth * (0.05 + (index * 0.08));
                            // Ensure cards don't go too far right on small screens
                            final adjustedRight = right > maxWidth * 0.6
                                ? maxWidth * (0.3 + (index * 0.05))
                                : right;

                            return Positioned(
                              top: top,
                              right: adjustedRight,
                              child: Transform.rotate(
                                angle: (index * 0.3) - 0.3, // Reduced rotation
                                child: Container(
                                  width: maxWidth *
                                      (maxWidth < 400
                                          ? 0.15
                                          : 0.20), // Slightly smaller
                                  height: maxHeight *
                                      (maxWidth < 400
                                          ? 0.1
                                          : 0.15), // Slightly smaller
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(maxWidth * 0.02),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: maxWidth * 0.02,
                                        offset: Offset(0, maxWidth * 0.01),
                                      ),
                                    ],
                                  ),
                                  // Add text content to cards with proper contrast
                                  child: Center(
                                    child: Icon(
                                      Icons.school,
                                      color: AppColors.primaryColor,
                                      size: maxWidth * 0.06,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(
                        height: maxHeight *
                            0.05), // Increased spacing to prevent overlap

                    // Ready to Start Learning Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: maxHeight * 0.03,
                        horizontal: maxWidth * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCardBackgroundColor.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(maxWidth * 0.03),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to Start Learning?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  maxHeight * (isSmallScreen ? 0.025 : 0.03),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: maxHeight * 0.01),
                          Text(
                            'Join thousands of students who use Deck Focus to improve their study habits.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize:
                                  maxHeight * (isSmallScreen ? 0.016 : 0.018),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: maxHeight * 0.02),
                          // Use Wrap instead of Row for better responsiveness on small screens
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: maxWidth * 0.03,
                            runSpacing: maxHeight * 0.01,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/deck');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: maxWidth * 0.04,
                                    vertical: maxHeight * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(maxWidth * 0.02),
                                  ),
                                ),
                                child: Text(
                                  'Explore Decks',
                                  style: TextStyle(
                                    fontSize: maxHeight *
                                        (isSmallScreen ? 0.016 : 0.018),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: maxWidth * 0.04,
                                    vertical: maxHeight * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(maxWidth * 0.02),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: maxHeight *
                                        (isSmallScreen ? 0.016 : 0.018),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Spacer that pushes footer to bottom when there's room
                    Spacer(),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(bottom: maxHeight * 0.02),
                      child: Column(
                        children: [
                          Text(
                            '© 2023 Deck Focus. All rights reserved.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: maxHeight * 0.016,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: maxHeight * 0.01),
                          // Use a Wrap widget instead of Row for better responsiveness
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: maxWidth * 0.02,
                            runSpacing: maxHeight * 0.01,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/aboutUs');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: maxWidth * 0.02,
                                    vertical: maxHeight * 0.005,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'About Us',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: maxHeight * 0.016,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: maxWidth * 0.02,
                                    vertical: maxHeight * 0.005,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: maxHeight * 0.016,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: maxWidth * 0.02,
                                    vertical: maxHeight * 0.005,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: maxHeight * 0.016,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
