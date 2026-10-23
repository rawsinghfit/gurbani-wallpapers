import 'package:flutter/widgets.dart';

import 'reward_result.dart';

Future<void> initAds() async {}

Future<bool> privacyOptionsRequired() async => false;

Future<void> showPrivacyOptions() async {}

const rewardedAdsEnabled = false;

void preloadRewardedAd() {}

Future<RewardResult> showRewardedAd() async => RewardResult.unavailable;

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
