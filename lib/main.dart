import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';

import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart'; // Import ApiClient and the provider
import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  // Add this line to initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize API client first
    final apiClient = ApiClient();
    await apiClient.initialize();
    print('API client initialized');
    // Get Supabase credentials
    final supabaseUrl = apiClient.getSupabaseUrl();
    final supabaseAnonKey = apiClient.getSupabaseAnonKey();
    
    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    final supabaseClient = Supabase.instance.client;
    print('Supabase initialized');
    // Add runApp call here
    runApp(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: MyApp(
          apiClient: apiClient,
          supabaseClient: supabaseClient,
        ),
      ),
    );
    
  } catch (e) {
    print('Failed to initialize services: $e');
    return;
  }
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final SupabaseClient supabaseClient;

  const MyApp({super.key, 
    required this.apiClient,
    required this.supabaseClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Study App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: RouteManager.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
