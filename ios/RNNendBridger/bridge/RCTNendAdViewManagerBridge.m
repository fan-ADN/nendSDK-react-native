//
//  RCTNendAdViewManagerBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(RCTNendAdViewManager, RCTViewManager)

RCT_EXTERN_METHOD(loadAd:(nonnull NSNumber *)reactTag);
RCT_EXTERN_METHOD(resume:(nonnull NSNumber *)reactTag);
RCT_EXTERN_METHOD(pause:(nonnull NSNumber *)reactTag);

RCT_EXPORT_VIEW_PROPERTY(spotId, NSString)
RCT_EXPORT_VIEW_PROPERTY(apiKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(adjustSize, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onAdLoaded, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdFailedToLoad, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClicked, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onInformationClicked, RCTBubblingEventBlock)

@end
