import 'package:flashcardstudyapplication/core/services/api/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart'; // Import ApiClient and the provider
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the ApiClient (which will fetch Supabase credentials)
  final apiClient = ApiClient();
  
 
  try {
    await apiClient.initialize();
  } catch (e) {
    print('Failed to initialize API Client $e');
     return; 
  }

    
  // Get Supabase credentials from ApiClient
  final supabaseUrl = apiClient.getSupabaseUrl(); // Method to get the Supabase URL
  final supabaseAnonKey = apiClient.getSupabaseAnonKey(); // Method to get the Supabase anon key

  // Initialize Supabase with the credentials
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabaseClient = Supabase.instance.client;

  final revClient = RevenueCat_Client(rev_key: apiClient.getRevenueCatApiKey());

  // Run the app and pass the initialized ApiClient and SupabaseClient to MyApp
  runApp(MyApp(apiClient: apiClient, supabaseClient: supabaseClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final SupabaseClient supabaseClient;

  const MyApp({required this.apiClient, required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Override the apiClientProvider with the initialized ApiClient
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: MaterialApp(
        title: 'Flashcard Study App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/mydecks',  // Set initial route if needed
        onGenerateRoute: RouteManager.generateRoute,  // Use the route manager
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
