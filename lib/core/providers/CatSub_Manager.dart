import 'dart:io';


import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flashcardstudyapplication/core/config/store_config.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';


class CatSubState {
  final bool isInitializing;
  final bool isInitialized;
  final String errorMessage;
  final bool hasSubscription;
  final List<Offering>? availablePackages;
  final String? customerID;

  CatSubState({
    this.isInitializing = false,
    this.isInitialized = false,
    this.errorMessage = '',
    this.hasSubscription = false,
    this.availablePackages,
    this.customerID,
  });

  CatSubState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    String? errorMessage,
    bool? hasSubscription,
    List<Offering>? availablePackages,
    String? customerID,
  }) {
    return CatSubState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSubscription: hasSubscription ?? this.hasSubscription,
      availablePackages: availablePackages ?? this.availablePackages,
      customerID: customerID ?? this.customerID,
    );
  }
}

class CatSubNotifier extends StateNotifier<CatSubState> {
  final Ref ref;

  CatSubNotifier(this.ref) : super(CatSubState());


  Future<void> initialize(String userId) async {
    
    state = state.copyWith(isInitializing: true);
    


    try {
      print('in the catsubmanager');
      if (Platform.isIOS) {
        StoreConfig(
            store: Stores.appleStore,
            apiKey: ApiManager.instance.getAppleAPI(),
        );
      } else if (Platform.isAndroid) {
        StoreConfig(
            store: Stores.googlePlay,
            apiKey: ApiManager.instance.getGoogleAPI(),
        );
      }

      // Get RevenueCat service from provider


      await ref.read(revenueCatClientProvider.notifier).initialize();
      // Initialize both services
      await ref.read(subscriptionProvider.notifier).initialize();

      // Fetch subscription status and packages
      await Future.wait([
        ref.read(subscriptionProvider.notifier).fetchSubscriptionStatus(userId),
        ref.read(subscriptionProvider.notifier).loadPackages(),
      ]);

      // Get customer info from RevenueCat service
      final customerInfo = await ref.read(userProvider).userId;
      final packages = await ref.read(revenueCatClientProvider.notifier).getOfferings();

      state = state.copyWith(
        isInitializing: false,
        isInitialized: true,
        hasSubscription: !ref.read(subscriptionProvider).isExpired,
        customerID: customerInfo,
        availablePackages: packages,
      );

      if(state.isInitialized == true){
        print('CatSubManager initialized');
      }

    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        errorMessage: e.toString(),

        
      );
      throw Exception(e);
    }
  }

  

  Future<void> restorePurchases() async {
    try {
      await ref.read(revenueCatClientProvider.notifier).restorePurchases();
     
     //handle database side with subscription provider
      
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> checkSubscriptionStatus(String userId, String entitlement) async {
    if (!state.isInitialized) {
      await initialize(userId);
      return;
    }
    try{
      
      await ref.read(revenueCatClientProvider.notifier).checkSubscriptionStatus(entitlement);

      //handle database side with subscription provider
      
     
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }


  Future<void> presentPaywall() async {
    
    await ref.read(revenueCatClientProvider.notifier).showPaywall();
  }
}

final catSubManagerProvider = StateNotifierProvider<CatSubNotifier, CatSubState>((ref) {
  final notifier = CatSubNotifier(ref);
  
  // Watch authState and trigger initialization when necessary.
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.isAuthenticated && next.user != null) {
      notifier.initialize(next.user!.id);
    }
  });

  return notifier;
});