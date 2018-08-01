//
//  RCTNendVideoNativeAdBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_REMAP_MODULE(NendVideoNativeAd, RCTNendVideoNativeAd, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize:(NSString *)spotId apiKey:(NSString *)apiKey clickOption:(NSInteger)clickOption);
RCT_EXTERN_METHOD(loadAd:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(registerClickableViews:(NSInteger)refernceId reactTags:(NSArray<NSNumber *> *)tags);
RCT_EXTERN_METHOD(setUserId:(NSString *)spotId userId:(NSString *)userId);
RCT_EXTERN_METHOD(setUserFeature:(NSString *)spotId refId:(NSInteger)refId);
RCT_EXTERN_METHOD(destroyLoader:(NSString *)spotId);
RCT_EXTERN_METHOD(destroyAd:(NSInteger)refId);

@end
