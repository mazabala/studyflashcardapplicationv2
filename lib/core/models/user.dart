// lib/core/models/user.dart

import 'package:flashcardstudyapplication/core/models/deck.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String subscriptionPlan;
  final DateTime subscriptionExpiry;
  final String isAdmin;
  final List<Deck> decks;
  
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.subscriptionPlan,
    required this.subscriptionExpiry,
    required this.isAdmin,
    required this.decks,
  });

  // Factory constructor to create a User from a map (e.g., API response)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      subscriptionPlan: map['subscription_plan'] as String,
      subscriptionExpiry: DateTime.parse(map['subscription_expiry'] as String),
      isAdmin: map['is_admin'] as String,
      decks: (map['decks'] as List<dynamic>).map((deck) => Deck.fromJson(deck)).toList(),
    );
  }

  // Method to convert User to a map (e.g., for API requests)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'subscription_plan': subscriptionPlan,
      'subscription_expiry': subscriptionExpiry.toIso8601String(),
      'is_admin': isAdmin,
      'decks': decks.map((deck) => deck.toJson()).toList(),
    };
  }
}
