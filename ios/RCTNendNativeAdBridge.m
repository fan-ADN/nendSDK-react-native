//
//  RCTNendNativeAdBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(NendNativeAd, RCTNendNativeAd, NSObject)

RCT_EXTERN_METHOD(loadAd:(NSString *)spotId apiKey:(NSString *)apiKey adExplicitly:(NSString *)adExplicitly resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(activate:(NSInteger)refId rootViewTag:(nonnull NSNumber *)rootViewTag prViewTag:(nonnull NSNumber *)prViewTag)
RCT_EXTERN_METHOD(destroyLoader:(NSString *)spotId)
RCT_EXTERN_METHOD(destroyAd:(NSInteger)refId)

@end
