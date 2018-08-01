//
//  RCTNendInterstitialAdBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_REMAP_MODULE(NendInterstitialAd, RCTNendInterstitialAd, RCTEventEmitter)

RCT_EXTERN_METHOD(loadAd:(NSString *)spotId apiKey:(NSString *)apiKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(show:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setAutoReloadEnabled:(BOOL)enabled);

@end
