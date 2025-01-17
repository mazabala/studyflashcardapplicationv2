import 'package:flashcardstudyapplication/core/providers/CatSub_Manager.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
//import 'package:revenuecat_ui/revenuecat_ui.dart';

class PricingScreen extends ConsumerStatefulWidget {
  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  @override
  void initState() {
    
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadPackages();
      
    });
  }



void presentPaywall() async {
  // Check authentication state
  final authState = ref.read(authProvider);
  
  if (!authState.isAuthenticated) {
    if (mounted) {
      // Show a dialog explaining why login is needed
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please log in to purchase a subscription.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamed(context, '/login'); // Navigate to login
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
    return; // Exit the method if not authenticated
  }

   ref.read(catSubManagerProvider.notifier).presentPaywall();

}
//  Future<void> _handleSubscription(String planName, double price) async {
//     final user = ref.read(userProvider);
    
//     // Check if user is logged in
//     if (user == null) {
//       // Navigate to login page
//       Navigator.pushNamed(context, '/login');
//       return;
//     }

//     // Get the subscription state
//     final subscriptionState = ref.read(subscriptionProvider);
    
//     // Find the matching package for the selected plan
//     final selectedPackage = subscriptionState.availablePackages?.firstWhere(
//       (package) => package.storeProduct.priceString == '\$${price.toString()}',
//       orElse: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Selected package not available')),
//         );
//         return subscriptionState.availablePackages!.first; // This line won't be reached
//       },
//     );

//     // Early return if packages are null or empty
//     if (subscriptionState.availablePackages == null || 
//         subscriptionState.availablePackages!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No packages available')),
//       );
//       return;
//     }

//     if (selectedPackage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Selected package not available')),
//       );
//       return;
//     }

//     try {

//       // final success = await ref.read(subscriptionProvider.notifier)
//       //     .purchasePackage(user?.userId ?? '', selectedPackage);

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Successfully subscribed to $planName plan!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to complete subscription')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      currentRoute: '/prices',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              _buildHeader(context),
              const SizedBox(height: 48),
              // Pricing Cards Section
              _buildPricingCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Choose Your Plan',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Select the perfect plan for your study needs',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPricingCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout
          return Column(
            children: [
              _buildPricingCard(context, 'Basic', 9.99),
              const SizedBox(height: 24),
              _buildPricingCard(context, 'Advanced', 14.99, isPremium: true),
            ],
          );
        } else {
          // Tablet and Desktop layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPricingCard(context, 'Basic', 9.99)),
              const SizedBox(width: 24),
              Expanded(child: _buildPricingCard(context, 'Advanced', 14.99, isPremium: true)),
            ],
          );
        }
      },
    );
  }

  Widget _buildPricingCard(BuildContext context, String planName, double price, {bool isPremium = false}) {
    final features = isPremium ? [
      'All Basic features',
      'Unlimited difficulty on decks',
      'Up to 60 flashcard decks',


    ] : [
      'Up to 15 flashcard decks',
      'Limited difficulty on decks'


    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPremium 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPremium 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$$price',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '/month',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isPremium) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Popular',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            
            // Features list
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 32),
            
            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //_handleSubscription(planName, price);
                  presentPaywall();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium 
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: isPremium 
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: isPremium
                  ? Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold,)
                  : Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}