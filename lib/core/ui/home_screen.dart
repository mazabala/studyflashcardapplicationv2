import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
 // Assuming there's a custom button widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting the current route to pass to the CustomAppBar
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return CustomScaffold(
      currentRoute: currentRoute,  // Pass the current route to customize the AppBar
      body:  SafeArea(
        child:
            Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Welcome to Your Flashcard Study Hub!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            Container(
                  
                 child:  Text('Maximize your learning potential with AI-powered flashcards. Whether you\'re studying for exams, learning a new language, or exploring a new hobby, our flashcard application provides you with smart, tailored decks that make studying more efficient and enjoyable.',
                 style: Theme.of(context).textTheme.bodyLarge,),
            ),
            const SizedBox(height: 30),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      
                     Text(
                        'How It Works:',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                       
                            ),
                      ),
                      const SizedBox(height: 10),
                      BulletPoint(text: "Create or Browse Decks: Choose from a wide range of pre-generated decks or create your own."),
                      const SizedBox(height: 10),
                      BulletPoint(text: "Study at Your Own Pace: Review your flashcards anytime, anywhere."),
                      const SizedBox(height: 10),
                      BulletPoint(text: "Track Your Progress: Stay motivated with in-depth progress tracking."),
                      const SizedBox(height: 10),
                      BulletPoint(text: "AI-Enhanced Learning: Personalized study recommendations."),
                        ],
                    ),
                    )
            ],
            ),
            

            const SizedBox(height: 30),
            
            Container(
              
              constraints: BoxConstraints(maxWidth: 400),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
              'Popular Decks:',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 10),
            BulletPoint(text: "History of Ancient Civilizations"),
            BulletPoint(text: "Spanish Vocabulary Builder"),
            BulletPoint(text: "Physics: Key Concepts and Formulas"),
            BulletPoint(text: "Math: Algebra and Geometry Essentials"),
            BulletPoint(text: "Medical Terminology"),
                ],),),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  //Navigator.pushNamed(context, RouteManager.deckScreen);
                },
                child: Text(
                   "Start Studying",
                       style: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Colors.white, // Ensuring the text is white
                       ),
                
                ),
              style:  ElevatedButton.styleFrom(
                 backgroundColor: Theme.of(context).colorScheme.primary, // Button background color
                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Adjust padding for a comfortable button size
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8), // Rounded corners
                 ),
                  )  ,
              ),
            ),
          ],
        ),
      ),
    ) 
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
