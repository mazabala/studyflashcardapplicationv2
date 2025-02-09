abstract class IApiManager {
  Future<void> initialize();

  String getRevenueCatApiKey();
  String getEntitlementID();
  String getGoogleAPI();
  String getAppleAPI();
  String getAmazonAPI();
  String getEntitlementName(String entitlementName);
}


