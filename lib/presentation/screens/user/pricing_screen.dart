import 'package:flashcardstudyapplication/core/providers/CatSub_Manager.dart';

import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/presentation/widgets/common/CustomScaffold.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
//import 'package:revenuecat_ui/revenuecat_ui.dart';

class PricingScreen extends ConsumerStatefulWidget {
  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(subscriptionStateProvider.notifier).initialize();

      ref.read(catSubManagerProvider.notifier).initialize();
    });
  }

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
              Expanded(
                  child: _buildPricingCard(context, 'Advanced', 14.99,
                      isPremium: true)),
            ],
          );
        }
      },
    );
  }

  Widget _buildPricingCard(BuildContext context, String planName, double price,
      {bool isPremium = false}) {
    final features = isPremium
        ? [
            'All Basic features',
            'Unlimited difficulty on decks',
            'Up to 60 flashcard decks',
          ]
        : ['Up to 15 flashcard decks', 'Limited difficulty on decks'];

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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextSpan(
                            text: '/month',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
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
                  isPremium
                      ? ref
                          .read(catSubManagerProvider.notifier)
                          .purchasePlan('premium', 'premium')
                      : ref
                          .read(catSubManagerProvider.notifier)
                          .purchasePlan('basic', 'basic');
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
                      ? Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          )
                      : Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
