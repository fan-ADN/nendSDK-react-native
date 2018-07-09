//
//  RCTNendVideoNativeAd.m
//  AwesomeProject
//

#import "RCTNendVideoNativeAd.h"
#import <React/RCTUIManager.h>

static NSString * const kRCTNendVideoNativeAdClickOptionFullScreen = @"FullScreen";
static NSString * const kRCTNendVideoNativeAdClickOptionLP = @"LP";
static NSString * const kRCTNendVideoNativeAdEventName = @"VideoNativeAdEventListener";

@import NendAd;

@interface NADNativeVideo (RCTExtension)

@end

@implementation NADNativeVideo (RCTExtension)

- (NSDictionary<NSString *, id> *)getJSONWithReferenceId:(NSInteger)refId
{
  return @{@"logoImageUrl": self.logoImageUrl,
           @"title": self.title,
           @"description": self.explanation,
           @"advertiserName": self.advertiserName,
           @"userRating": @(self.userRating),
           @"userRatingCount": @(self.userRatingCount),
           @"callToAction": self.callToAction,
           @"referenceId": @(refId)};
}

@end

#pragma mark -

@interface RCTNendVideoNativeAd () <NADNativeVideoDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NADNativeVideoLoader *> *loaderCache;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NADNativeVideo *> *videoAdCache;
@property (nonatomic, strong) NSMapTable<NADNativeVideo *, NSNumber *> *videoAdToReferenceId;
@property (nonatomic) NSInteger referenceId;
@property (nonatomic) BOOL hasListeners;

@end

@implementation RCTNendVideoNativeAd

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(NendVideoNativeAd)

RCT_EXPORT_METHOD(initialize:(NSString *)spotId apiKey:(NSString *)apiKey clickOption:(NSInteger)clickOption)
{
  NADNativeVideoLoader *loader = self.loaderCache[spotId];
  if (!loader) {
    loader = [[NADNativeVideoLoader alloc] initWithSpotId:spotId
                                                   apiKey:apiKey
                                              clickAction:(NADNativeVideoClickAction)clickOption];
    self.loaderCache[spotId] = loader;
  }
}

RCT_EXPORT_METHOD(loadAd:(NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NADNativeVideoLoader *loader = self.loaderCache[spotId];
  if (loader) {
    __weak typeof(self) weakSelf = self;
    [loader loadAdWithCompletionHandler:^(NADNativeVideo * _Nullable ad, NSError * _Nullable error) {
      if (ad) {
        ad.delegate = weakSelf;
        NSInteger refId = ++weakSelf.referenceId;
        weakSelf.videoAdCache[@(refId)] = ad;
        [weakSelf.videoAdToReferenceId setObject:@(refId) forKey:ad];
        resolve([ad getJSONWithReferenceId:refId]);
      } else {
        reject(@"", @"", error);
      }
    }];
  }
}

RCT_EXPORT_METHOD(registerClickableViews:(nonnull NSNumber *)refernceId tags:(NSArray<NSNumber *> *)tags)
{
  NADNativeVideo *videoAd = self.videoAdCache[refernceId];
  if (videoAd && tags && tags.count > 0) {
    NSMutableArray<UIView *> *views = [NSMutableArray array];
    [tags enumerateObjectsUsingBlock:^(NSNumber * _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
      UIView *view = [self.bridge.uiManager viewForReactTag:tag];
      if (view) {
        [views addObject:view];
      }
    }];
    if (views.count > 0) {
      [videoAd registerInteractionViews:views];
    }
  }
}

RCT_EXPORT_METHOD(destroyLoader:(NSString *)spotId)
{
  [self.loaderCache removeObjectForKey:spotId];
}

RCT_EXPORT_METHOD(destroyAd:(nonnull NSNumber *)refernceId)
{
  [self.videoAdCache removeObjectForKey:refernceId];
}

- (NSDictionary *)constantsToExport
{
  return @{kRCTNendVideoNativeAdClickOptionFullScreen: @1, kRCTNendVideoNativeAdClickOptionLP: @2};
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[kRCTNendVideoNativeAdEventName];
}

- (void)startObserving
{
  self.hasListeners = YES;
}

- (void)stopObserving
{
  self.hasListeners = NO;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _loaderCache = [NSMutableDictionary new];
    _videoAdCache = [NSMutableDictionary new];
    _videoAdToReferenceId = [NSMapTable weakToStrongObjectsMapTable];
    _referenceId = 0;
    _hasListeners = NO;
  }
  return self;
}

- (NADNativeVideo *)getVideoAdWithRefernceId:(NSInteger)referenceId
{
  return self.videoAdCache[@(referenceId)];
}

- (void)sendEventWithVideoAd:(NADNativeVideo *)videoAd eventType:(NSString *)eventType
{
  NSNumber *refId = [self.videoAdToReferenceId objectForKey:videoAd];
  if (refId && self.hasListeners) {
    [self sendEventWithName:kRCTNendVideoNativeAdEventName body:@{@"refId": refId, @"eventType": eventType}];
  }
}

#pragma mark - NADNativeVideoDelegate

- (void)nadNativeVideoDidImpression:(NADNativeVideo * _Nonnull)ad
{
  [self sendEventWithVideoAd:ad eventType:@"onImpression"];
}

- (void)nadNativeVideoDidClickAd:(NADNativeVideo * _Nonnull)ad
{
  [self sendEventWithVideoAd:ad eventType:@"onClickAd"];
}

- (void)nadNativeVideoDidClickInformation:(NADNativeVideo * _Nonnull)ad
{
  [self sendEventWithVideoAd:ad eventType:@"onClickInformation"];
}

@end
