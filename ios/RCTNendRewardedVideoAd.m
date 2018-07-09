//
//  RCTNendRewardedVideoAd.m
//  AwesomeProject
//

#import "RCTNendRewardedVideoAd.h"

static NSString * const kRCTNendRewardedVideoAdEventName = @"RewardedVideoAdEventListener";

@interface RCTNendRewardedVideoAd () <NADRewardedVideoDelegate>

@end

@implementation RCTNendRewardedVideoAd

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_MODULE(NendRewardedVideoAd)

- (NSArray<NSString *> *)supportedEvents
{
  return @[kRCTNendRewardedVideoAdEventName];
}

- (NADVideo *)createVideoAdWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey
{
  NADRewardedVideo *videoAd = [[NADRewardedVideo alloc] initWithSpotId:spotId apiKey:apiKey];
  videoAd.delegate = self;
  return videoAd;
}

- (NSString *)eventName
{
  return kRCTNendRewardedVideoAdEventName;
}

#pragma NADRewardedVideoDelegate

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didLoadVideoAd:nadRewardedVideoAd withError:nil];
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error
{
  [self didLoadVideoAd:nadRewardedVideoAd withError:error];
}

- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didFailPlaybackVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didShowVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didCloseVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didStartPlaybackVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didStopPlaybackVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didCompletePlaybackVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didClickVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd
{
  [self didClickInformationVideoAd:nadRewardedVideoAd];
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward
{
  [self sendEventWithVideoAd:nadRewardedVideoAd
                   eventType:@"onRewarded"
                        body:@{@"rewardName": reward.name, @"rewardAmount": @(reward.amount)}];
}

@end
