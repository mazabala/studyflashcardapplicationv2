import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    final userNotifier = ref.read(userProvider.notifier);
     

    return CustomScaffold(
      currentRoute: '/userProfile',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 800 : constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              child: Icon(Icons.person, size: 50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Profile',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subscription Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name:\n${userState.firstName} ${userState.lastName}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                               const SizedBox(height: 8),
                            Text(
                              'Current Plan:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              userState.subscriptionPlan ?? 'No active subscription',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                              const SizedBox(height: 8),
                            Text(
                              'Status:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  userState.isExpired ?? true
                                      ? 'Expired'
                                      : 'Active',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  userState.isExpired ?? true
                                      ? Icons.error_outline
                                      : Icons.check_circle,
                                  color: userState.isExpired ?? true
                                      ? AppColors.errorColor
                                      : Colors.green,
                                ),
                                
                                
                              ],
                            ),
                            const SizedBox(height: 8),
                              Text(
                              'Expiration Date: ${userState.subscriptionExpiryDate}',
                              style: Theme.of(context).textTheme.bodyLarge,
                                ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    CustomButton(
                      text: 'Manage Subscription',
                      onPressed: () {
                        Navigator.pushNamed(context, '/prices');
                      },
                      isLoading: false,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        editProfileDialog(context, ref);
                      },
                      isLoading: false,
                    ),
                    if (userState.errorMessage != null) ...[
                      Text(
                        userState.errorMessage!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> editProfileDialog(BuildContext context, WidgetRef ref) async {

    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    final userNotifier = ref.read(userProvider.notifier);
    final userState = ref.watch(userProvider);
    


    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController ,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController ,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Save',
              icon: Icons.save,
              onPressed: () {
                userNotifier.userService.updateUserProfile(
                   firstNameController.text,
                   lastNameController.text,
                   userState.userId??''
                );

                  Navigator.pop(context);
                
              },
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
