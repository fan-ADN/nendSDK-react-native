//
//  RCTNendInterstitialVideoAd.m
//  AwesomeProject
//

#import "RCTNendInterstitialVideoAd.h"

static NSString * const kRCTNendInterstitialVideoAdEventName = @"InterstitialVideoAdEventListener";

@interface RCTNendInterstitialVideoAd () <NADInterstitialVideoDelegate>

@end

@implementation RCTNendInterstitialVideoAd

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_MODULE(NendInterstitialVideoAd)

RCT_EXPORT_METHOD(addFallbackFullBoard:(nonnull NSString *)spotId
                  fullboardSpotId:(NSString *)fullboardSpotId
                  fullBoardApiKey:(NSString *)fullBoardApiKey)
{
  NADInterstitialVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (videoAd) {
    [videoAd addFallbackFullboardWithSpotId:fullboardSpotId apiKey:fullBoardApiKey];
  }
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[kRCTNendInterstitialVideoAdEventName];
}

- (NADVideo *)createVideoAdWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey
{
  NADInterstitialVideo *videoAd = [[NADInterstitialVideo alloc] initWithSpotId:spotId apiKey:apiKey];
  videoAd.delegate = self;
  return videoAd;
}

- (NSString *)eventName
{
  return kRCTNendInterstitialVideoAdEventName;
}

#pragma mark - NADInterstitialVideoDelegate

- (void)nadInterstitialVideoAdDidReceiveAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didLoadVideoAd:nadInterstitialVideoAd withError:nil];
}

- (void)nadInterstitialVideoAd:(NADInterstitialVideo *)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error
{
  [self didLoadVideoAd:nadInterstitialVideoAd withError:error];
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didFailPlaybackVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidOpen:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didShowVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidClose:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didCloseVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidStartPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didStartPlaybackVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidStopPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didStopPlaybackVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidCompletePlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didCompletePlaybackVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidClickAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didClickVideoAd:nadInterstitialVideoAd];
}

- (void)nadInterstitialVideoAdDidClickInformation:(NADInterstitialVideo *)nadInterstitialVideoAd
{
  [self didClickInformationVideoAd:nadInterstitialVideoAd];
}

@end
