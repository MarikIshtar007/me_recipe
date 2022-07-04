import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  late Future<InitializationStatus> initialization;

  AdState() {
    initialization = MobileAds.instance.initialize();
  }

  BannerAdListener get adListener => _adListener;

  final BannerAdListener _adListener = BannerAdListener(
    onAdOpened: (ad) {
      debugPrint('Ad opened: ${ad.adUnitId}');
    },
    onAdClicked: (ad) {
      debugPrint('Ad clicked: ${ad.adUnitId}');
    },
    onAdClosed: (ad) {
      debugPrint('Ad closed: ${ad.adUnitId}');
    },
    onAdFailedToLoad: (ad, error) {
      debugPrint('Ad failed: ${ad.adUnitId}, Error: $error');
    },
    onAdImpression: (ad) {
      debugPrint('Ad impression: ${ad.adUnitId}');
    },
    onAdLoaded: (ad) {
      debugPrint('Ad loaded: ${ad.adUnitId}');
    },
    onAdWillDismissScreen: (ad) {
      debugPrint('Ad dismissed: ${ad.adUnitId}');
    },
    onPaidEvent: (ad, _, __, ___) {
      debugPrint('Ad opened: ${ad.adUnitId}');
    },
  );
}
