enum RewardResult {
  /// The user watched the ad to the end.
  earned,

  /// The user closed the ad before the reward.
  skipped,

  /// No ad could be shown (offline, no fill, no consent, web).
  unavailable,
}
