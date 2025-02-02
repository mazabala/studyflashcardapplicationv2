class Subscription {
  final String subscriptionName;
  final String subscriptionId;
  final String subscriptionStatus;

  Subscription({
    required this.subscriptionName,
    required this.subscriptionId,
    required this.subscriptionStatus,
  });

  // Factory constructor to create from Supabase JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionName: json['name'] as String,
      subscriptionId: json['id'] as String,
      subscriptionStatus: json['status'] ?? 'inactive',
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': subscriptionName,
      'id': subscriptionId,
      'status': subscriptionStatus,
    };
  }
}


