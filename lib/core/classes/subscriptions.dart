class Subscription {
  final String subscriptionName;
  final String subscriptionId;
  final String subscriptionStatus;
  final String createdAt;


  Subscription({
    required this.subscriptionName,
    required this.subscriptionId,
    required this.subscriptionStatus,
    required this.createdAt,
  });


  // Factory constructor to create from Supabase JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    print('json - $json');
    return Subscription(
      subscriptionName: json['name'] as String,
      subscriptionId: json['subscriptionType_id'] as String,
      subscriptionStatus: (json['is_active'] as bool).toString(),
      createdAt: json['created_at'] as String,
    );
  }



  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': subscriptionName,
      'subscriptionType_id': subscriptionId,
      'is_active': subscriptionStatus,
      'created_at': createdAt,

    };
  }
}


