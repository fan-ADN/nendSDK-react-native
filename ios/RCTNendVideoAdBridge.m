//
//  RCTNendVideoAdBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_REMAP_MODULE(NendRewardedVideoAd, RCTNendRewardedVideoAd, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize:(NSString *)spotId apiKey:(NSString *)apiKey);
RCT_EXTERN_METHOD(loadAd:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(isLoaded:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(show:(NSString *)spotId);
RCT_EXTERN_METHOD(setUserId:(NSString *)spotId userId:(NSString *)userId);
RCT_EXTERN_METHOD(setUserFeature:(NSString *)spotId refId:(NSInteger)refId);
RCT_EXTERN_METHOD(destroy:(NSString *)spotId);

@end

@interface RCT_EXTERN_REMAP_MODULE(NendInterstitialVideoAd, RCTNendInterstitialVideoAd, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize:(NSString *)spotId apiKey:(NSString *)apiKey);
RCT_EXTERN_METHOD(loadAd:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(isLoaded:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(show:(NSString *)spotId);
RCT_EXTERN_METHOD(setUserId:(NSString *)spotId userId:(NSString *)userId);
RCT_EXTERN_METHOD(setUserFeature:(NSString *)spotId refId:(NSInteger)refId);
RCT_EXTERN_METHOD(destroy:(NSString *)spotId);
RCT_EXTERN_METHOD(addFallbackFullBoard:(NSString *)spotId fullboardSpotId:(NSString *)fullboardSpotId fullBoardApiKey:(NSString *)fullBoardApiKey);

@end
