//
//  RCTNendVideoAd.m
//  AwesomeProject
//

#import "RCTNendVideoAd.h"
#import "RCTNendPromise.h"

#pragma mark -

@interface RCTNendVideoAd ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, __kindof NADVideo *> *instanceCache;
@property (nonatomic, strong) NSMapTable<__kindof NADVideo *, NSString *> *instanceToSpotId;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<RCTNendPromise *> *> *loadPromises;
@property (nonatomic) BOOL hasListeners;

@end

@implementation RCTNendVideoAd

RCT_EXPORT_METHOD(initialize:(nonnull NSString *)spotId apiKey:(nonnull NSString *)apiKey)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (!videoAd) {
    videoAd = [self createVideoAdWithSpotId:spotId apiKey:apiKey];
    self.instanceCache[spotId] = videoAd;
    [self.instanceToSpotId setObject:spotId forKey:videoAd];
  }
}

RCT_EXPORT_METHOD(loadAd:(nonnull NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (videoAd) {
    RCTNendPromise *promise = [[RCTNendPromise alloc] initWithResolveBlock:resolve rejectBlock:reject];
    NSMutableArray<RCTNendPromise *> *promises = self.loadPromises[spotId];
    if (promises) {
      [promises addObject:promise];
      return;
    }
    self.loadPromises[spotId] = [@[promise] mutableCopy];
    [videoAd loadAd];
  }
}

RCT_EXPORT_METHOD(isLoaded:(nonnull NSString *)spotId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  BOOL ret = videoAd && videoAd.isReady;
  resolve([NSNumber numberWithBool:ret]);
}

RCT_EXPORT_METHOD(show:(nonnull NSString *)spotId)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (videoAd) {
    [videoAd showAdFromViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
  }
}

RCT_EXPORT_METHOD(setUserId:(nonnull NSString *)spotId userId:(NSString *)userId)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (videoAd) {
    videoAd.userId = userId;
  }
}

RCT_EXPORT_METHOD(destroy:(nonnull NSString *)spotId)
{
  NADVideo *videoAd = [self getVideoAdWithSpotId:spotId];
  if (videoAd) {
    [videoAd releaseVideoAd];
    [self.instanceCache removeObjectForKey:spotId];
  }
  [self.loadPromises removeObjectForKey:spotId];
}

- (NSArray<NSString *> *)supportedEvents
{
  return nil;
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
    _instanceCache = [NSMutableDictionary new];
    _instanceToSpotId = [NSMapTable weakToStrongObjectsMapTable];
    _loadPromises = [NSMutableDictionary new];
  }
  return self;
}

- (NADVideo *)createVideoAdWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey
{
  return nil;
}

- (NADVideo * _Nullable)getVideoAdWithSpotId:(NSString *)spotId
{
  return self.instanceCache[spotId];
}

- (NSString *)getSpotIdForVideoAd:(NADVideo *)videoAd
{
  return [self.instanceToSpotId objectForKey:videoAd];
}

- (void)didLoadVideoAd:(NADVideo *)videoAd withError:(NSError *)error
{
  NSString *spotId = [self.instanceToSpotId objectForKey:videoAd];
  if (spotId) {
    NSMutableArray<RCTNendPromise *> *promises = self.loadPromises[spotId];
    if (promises) {
      [promises enumerateObjectsUsingBlock:^(RCTNendPromise * _Nonnull promise, NSUInteger idx, BOOL * _Nonnull stop) {
        if (error) {
          promise.reject(@(error.code).stringValue, error.localizedDescription, error);
        } else {
          promise.resolve(nil);
        }
      }];
      [self.loadPromises removeObjectForKey:spotId];
    }
  }
}

- (void)didShowVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoShown"];
}

- (void)didCloseVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoClosed"];
}

- (void)didFailPlaybackVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoPlaybackError"];
}

- (void)didStartPlaybackVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoPlaybackStarted"];
}

- (void)didStopPlaybackVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoPlaybackStopped"];
}

- (void)didCompletePlaybackVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoPlaybackCompleted"];
}

- (void)didClickVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoAdClicked"];
}

- (void)didClickInformationVideoAd:(NADVideo *)videoAd
{
  [self sendEventWithVideoAd:videoAd eventType:@"onVideoAdInformationClicked"];
}

- (void)sendEventWithVideoAd:(NADVideo *)videoAd eventType:(NSString *)type
{
  [self sendEventWithVideoAd:videoAd eventType:type body:nil];
}

- (void)sendEventWithVideoAd:(NADVideo *)videoAd eventType:(NSString *)type body:(NSDictionary<NSString *, id> *)body
{
  if (!self.hasListeners) {
    return;
  }
  NSString *spotId = [self.instanceToSpotId objectForKey:videoAd];
  if (spotId) {
    NSMutableDictionary<NSString *, id> *args;
    if (body) {
      args = [NSMutableDictionary dictionaryWithDictionary:body];
    } else {
      args = [NSMutableDictionary dictionary];
    }
    args[@"spotId"] = spotId;
    args[@"eventType"] = type;
    [self sendEventWithName:self.eventName body:args];
  }
}

@end
