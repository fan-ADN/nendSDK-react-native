//
//  RCTNendInterstitialAd.m
//  AwesomeProject
//

#import "RCTNendInterstitialAd.h"
#import "RCTNendPromise.h"

static NSString * const kRCTNendInterstitialAdEventClosed = @"onInterstitialAdClosed";

@import NendAd;

@interface RCTNendInterstitialAd () <NADInterstitialDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<RCTNendPromise *> *> *loadPromises;
@property (nonatomic) BOOL hasListeners;

@end

@implementation RCTNendInterstitialAd

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_MODULE(NendInterstitialAd)

RCT_EXPORT_METHOD(loadAd:(nonnull NSString *)spotId apiKey:(nonnull NSString *)apiKey
                  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NSMutableArray<RCTNendPromise *> *promises = self.loadPromises[spotId];
  RCTNendPromise *promise = [[RCTNendPromise alloc] initWithResolveBlock:resolve rejectBlock:reject];
  if (promises) {
    [promises addObject:promise];
    return;
  }
  promises = [NSMutableArray arrayWithObject:promise];
  self.loadPromises[spotId] = promises;
  [[NADInterstitial sharedInstance] loadAdWithApiKey:apiKey spotId:spotId];
}

RCT_EXPORT_METHOD(show:(nonnull NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
  NADInterstitialShowResult result = [[NADInterstitial sharedInstance] showAdFromViewController:vc spotId:spotId];
  if (result == AD_SHOW_SUCCESS) {
    resolve(nil);
  } else {
    reject(@"", [self getErrorStringWithShowResult:result], nil);
  }
}

RCT_EXPORT_METHOD(setAutoReloadEnabled:(BOOL)enabled)
{
  [NADInterstitial sharedInstance].enableAutoReload = enabled;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _loadPromises = [NSMutableDictionary new];
    [NADInterstitial sharedInstance].delegate = self;
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[kRCTNendInterstitialAdEventClosed];
}

- (void)startObserving
{
  self.hasListeners = YES;
}

- (void)stopObserving
{
  self.hasListeners = NO;
}

#pragma mark - NADInterstitialDelegate

- (void)didFinishLoadInterstitialAdWithStatus:(NADInterstitialStatusCode)status spotId:(NSString *)spotId
{
  NSMutableArray<RCTNendPromise *> *promises = self.loadPromises[spotId];
  if (promises) {
    [promises enumerateObjectsUsingBlock:^(RCTNendPromise * _Nonnull promise, NSUInteger idx, BOOL * _Nonnull stop) {
      if (status == SUCCESS) {
        promise.resolve(nil);
      } else {
        promise.reject(@"", [self getErrorStringWithStatusCode:status], nil);
      }
    }];
    [self.loadPromises removeObjectForKey:spotId];
  }
}

- (void)didClickWithType:(NADInterstitialClickType)type spotId:(NSString *)spotId
{
  if (!self.hasListeners) {
    return;
  }
  NSMutableDictionary<NSString *, id> *body = [NSMutableDictionary new];
  body[@"spotId"] = spotId;
  body[@"clickType"] = [self getStringWithClickType:type];
  [self sendEventWithName:kRCTNendInterstitialAdEventClosed body:body];
}

- (NSString *)getStringWithClickType:(NADInterstitialClickType)type
{
  switch (type) {
    case DOWNLOAD:
      return @"DOWNLOAD";
    case CLOSE:
      return @"CLOSE";
    case INFORMATION:
      return @"INFORMATION";
    default:
      return @"";
  }
}

- (NSString *)getErrorStringWithStatusCode:(NADInterstitialStatusCode)code
{
  switch (code) {
    case FAILED_AD_REQUEST:
      return @"FAILED_AD_REQUEST";
    case FAILED_AD_DOWNLOAD:
      return @"FAILED_AD_DOWNLOAD";
    case INVALID_RESPONSE_TYPE:
      return @"INVALID_RESPONSE_TYPE";
    default:
      return @"";
  }
}

- (NSString *)getErrorStringWithShowResult:(NADInterstitialShowResult)result
{
  switch (result) {
    case AD_CANNOT_DISPLAY:
      return @"AD_CANNOT_DISPLAY";
    case AD_DOWNLOAD_INCOMPLETE:
      return @"AD_DOWNLOAD_INCOMPLETE";
    case AD_REQUEST_INCOMPLETE:
      return @"AD_REQUEST_INCOMPLETE";
    case AD_LOAD_INCOMPLETE:
      return @"AD_LOAD_INCOMPLETE";
    case AD_FREQUENCY_NOT_REACHABLE:
      return @"AD_FREQUENCY_NOT_REACHABLE";
    case AD_SHOW_ALREADY:
      return @"AD_SHOW_ALREADY";
    default:
      return @"";
  }
}

@end
