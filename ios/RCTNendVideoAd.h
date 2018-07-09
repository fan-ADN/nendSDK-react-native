//
//  RCTNendVideoAd.h
//  AwesomeProject
//

#import <Foundation/Foundation.h>

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@import NendAd;

NS_ASSUME_NONNULL_BEGIN
@interface RCTNendVideoAd<T: NADVideo *> : RCTEventEmitter <RCTBridgeModule>

@property (readonly, nonatomic, copy) NSString *eventName;

- (T)createVideoAdWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (T _Nullable)getVideoAdWithSpotId:(NSString *)spotId;
- (NSString * _Nullable)getSpotIdForVideoAd:(T)videoAd;
- (void)didLoadVideoAd:(T)videoAd withError:(NSError * _Nullable)error;
- (void)didShowVideoAd:(T)videoAd;
- (void)didCloseVideoAd:(T)videoAd;
- (void)didFailPlaybackVideoAd:(T)videoAd;
- (void)didStartPlaybackVideoAd:(T)videoAd;
- (void)didStopPlaybackVideoAd:(T)videoAd;
- (void)didCompletePlaybackVideoAd:(T)videoAd;
- (void)didClickVideoAd:(T)videoAd;
- (void)didClickInformationVideoAd:(T)videoAd;
- (void)sendEventWithVideoAd:(NADVideo *)videoAd eventType:(NSString *)type body:(NSDictionary<NSString *, id> * _Nullable)body;

@end
NS_ASSUME_NONNULL_END
