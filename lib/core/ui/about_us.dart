import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CustomScaffold(
      currentRoute: '/aboutUs',
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // 5% padding of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height for spacing

            // Using Row to place text on the left and image on the right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Text content (dynamic width)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap text in Container to control width
                      Container(
                        width: screenWidth < 600 ? screenWidth : 600, // Adjust text width dynamically
                        padding: EdgeInsets.only(right: screenWidth * 0.05), // Add some padding to the text
                        child: _buildIntroText(context),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                      Container(
                        width: screenWidth < 600 ? screenWidth : 600, // Adjust text width dynamically
                        padding: EdgeInsets.only(right: screenWidth * 0.05),
                        child: _buildMissionText(context),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                      Container(
                        width: screenWidth < 600 ? screenWidth : 600, // Adjust text width dynamically
                        padding: EdgeInsets.only(right: screenWidth * 0.05),
                        child: _buildChallengesText(context),
                      ),
                    ],
                  ),
                ),
                
                // Right Side: Image Placeholder (dynamic square size)
                if (screenWidth > 800) // Show image only on larger screens (web/tablets)
                  Expanded(
                    flex: 2,
                    child: _buildImagePlaceholder(screenHeight),
                  ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing
            _buildTestimonials(context),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing
            _buildAppFeatures(context),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing
            _buildCallToAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText(BuildContext context) {
    return Text(
      'My name is [Your Name], and I have always been a hardworking individual who struggled with the traditional methods of studying throughout my academic journey. From school to college and grad school, I encountered challenges in finding the right tools to help me learn efficiently.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildMissionText(BuildContext context) {
    return Text(
      'That is why I created Brain Decks: an app designed to make studying easier, more engaging, and efficient. Deck Focus isn’t just another flashcard app; it is a tool that integrates seamlessly into your daily life, offering an intuitive and simple way to retain knowledge.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildChallengesText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Struggles with Traditional Study Tools',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Many of the study tools I used in the past were outdated, clunky, and hard to understand. Some of them were full of bugs, while others didn’t offer the flexibility I needed to retain knowledge effectively. The learning process shouldn’t be this frustrating, especially when the goal is to make students succeed. That’s when the idea for Brain Decks came to life.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // Image Placeholder (Right side of the screen, square)
  Widget _buildImagePlaceholder(double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.5, // 30% of screen height for image placeholder
      color: Colors.grey[300], // Placeholder color
      child: const Center(
        child: Text(
          'Image Placeholder',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }

  // Testimonials section
  Widget _buildTestimonials(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Our Users Say',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '"Brain Decks made studying so much easier for me! The flashcards are simple, and I love how intuitive the app is." - User A',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          '"I struggled with other apps, but Brain Decks is different. It really helped me retain information faster." - User B',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          '"The best study app I’ve used so far. It fits perfectly into my study routine and helps me stay organized!" - User C',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // App features section
  Widget _buildAppFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features of Brain Decks',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.check, color: Colors.green),
            SizedBox(width: 10),
            Expanded(child: Text('Customizable flashcards that suit your learning style.')),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.check, color: Colors.green),
            SizedBox(width: 10),
            Expanded(child: Text('Adaptive learning algorithms that help you study smarter.')),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.check, color: Colors.green),
            SizedBox(width: 10),
            Expanded(child: Text('Easy-to-use interface that helps you focus on what matters.')),
          ],
        ),
      ],
    );
  }

  // Call to action
  Widget _buildCallToAction(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Mission',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Brain Decks was designed with students in mind. We want to help you save time, reduce stress, and make studying a more enjoyable experience. Whether you are a high school student trying to ace your exams, a college student dealing with endless lecture notes, or a grad student navigating complex topics, Brain Decks is here to simplify your study routine.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Navigate to the DeckScreen on button press
            Navigator.pushNamed(context, '/deck');
          },
          child: const Text('Start Studying Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Colors.white,)
          ),
        ),
      ],
    );
  }
}
