//
//  RCTNendNativeAd.m
//  AwesomeProject
//

#import "RCTNendNativeAd.h"
#import <React/RCTUIManager.h>

@import NendAd;

@interface NADNative (RCTExtension)

@end

@implementation NADNative (RCTExtension)

- (NSDictionary<NSString *, id> *)getJSONWithReferenceId:(NSInteger)refId adExplicitly:(NADNativeAdvertisingExplicitly)explicitly
{
  return @{@"adImageUrl": self.imageUrl,
           @"logoImageUrl": self.logoUrl ?: @"",
           @"title": self.shortText,
           @"content": self.longText,
           @"promotionName": self.promotionName,
           @"promotionUrl": self.promotionUrl,
           @"callToAction": self.actionButtonText,
           @"adExplicitly": [self prTextForAdvertisingExplicitly:explicitly],
           @"referenceId": @(refId)};
}

@end

#pragma mark -

@interface RCTNendNativeAd ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NADNativeClient *> *clientCache;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NADNative *> *nativeAdCache;
@property (nonatomic, strong) NSArray<NSString *> *adExplicitlyList;
@property (nonatomic) NSInteger referenceId;

@end

@implementation RCTNendNativeAd

@synthesize bridge = _bridge;

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(NendNativeAd)

- (instancetype)init
{
  self = [super init];
  if (self) {
    _clientCache = [NSMutableDictionary new];
    _nativeAdCache = [NSMutableDictionary new];
    _adExplicitlyList = @[@"PR", @"Sponsored", @"AD", @"Promotion"];
    _referenceId = 0;
  }
  return self;
}

RCT_EXPORT_METHOD(loadAd:(NSString *)spotId
                  apiKey:(NSString *)apiKey
                  adExplicitly:(NSString *)adExplicitly
                  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NADNativeClient *client = self.clientCache[spotId];
  if (!client) {
    client = [[NADNativeClient alloc] initWithSpotId:spotId apiKey:apiKey];
    self.clientCache[spotId] = client;
  }
  __weak typeof(self) weakSelf = self;
  [client loadWithCompletionBlock:^(NADNative *ad, NSError *error) {
    if (weakSelf) {
      if (ad) {
        NSInteger refId = ++weakSelf.referenceId;
        weakSelf.nativeAdCache[@(refId)] = ad;
        resolve([ad getJSONWithReferenceId:refId
                              adExplicitly:[weakSelf.adExplicitlyList indexOfObject:adExplicitly]]);
      } else {
        reject(error.domain, error.localizedDescription, error);
      }
    }
  }];
}

RCT_EXPORT_METHOD(activate:(nonnull NSNumber *)refId rootViewTag:(nonnull NSNumber *)rootViewTag prViewTag:(nonnull NSNumber *)prViewTag)
{
  NADNative *nativeAd = self.nativeAdCache[refId];
  if (nativeAd) {
    UIView *rootView = [self.bridge.uiManager viewForReactTag:rootViewTag];
    UIView *prView = [self.bridge.uiManager viewForReactTag:prViewTag];
    if (rootView && prView) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
      [nativeAd activateAdView:rootView withPrLabel:prView];
#pragma clang diagnostic pop
    }
  }
}

RCT_EXPORT_METHOD(destroyLoader:(NSString *)spotId)
{
  [self.clientCache removeObjectForKey:spotId];
}

RCT_EXPORT_METHOD(destroyAd:(nonnull NSNumber *)refId)
{
  [self.nativeAdCache removeObjectForKey:refId];
}

@end
