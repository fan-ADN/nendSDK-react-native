//
//  RCTNendAdViewManager.m
//  AwesomeProject
//

#import "RCTNendAdViewManager.h"

#import <React/RCTView.h>
#import <React/RCTUIManager.h>

@import NendAd;

@interface RCTNADView : RCTView <NADViewDelegate>

@property (nonatomic, strong) NADView *adView;
@property (nonatomic, copy) NSString *spotId;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic) BOOL adjustSize;
@property (nonatomic, copy) RCTBubblingEventBlock onAdLoaded;
@property (nonatomic, copy) RCTBubblingEventBlock onAdFailedToLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onAdClicked;
@property (nonatomic, copy) RCTBubblingEventBlock onInformationClicked;

@end

@implementation RCTNADView

- (void)loadAd
{
  if (self.spotId && self.apiKey) {
    if (!self.adView) {
      self.adView = [[NADView alloc] initWithIsAdjustAdSize:self.adjustSize];
      [self addSubview:self.adView];
      self.adView.delegate = self;
      [self.adView setNendID:self.apiKey spotID:self.spotId];
      [self.adView load];
    }
  }
}

#pragma mark - NADViewDelegate

- (void)nadViewDidReceiveAd:(NADView *)adView
{
  if (self.onAdLoaded) {
    NSDictionary<NSString *, NSNumber *> *body = @{@"width": @(CGRectGetWidth(self.adView.bounds)),
                                                   @"height": @(CGRectGetHeight(self.adView.bounds))};
    self.onAdLoaded(body);
  }
}

- (void)nadViewDidFailToReceiveAd:(NADView *)adView
{
  if (self.onAdFailedToLoad) {
    NSError *error = adView.error;
    NSDictionary<NSString *, id> *body = @{@"code": @(error.code), @"message": error.domain};
    self.onAdFailedToLoad(body);
  }
}

- (void)nadViewDidClickAd:(NADView *)adView
{
  if (self.onAdClicked) {
    self.onAdClicked(nil);
  }
}

- (void)nadViewDidClickInformation:(NADView *)adView
{
  if (self.onInformationClicked) {
    self.onInformationClicked(nil);
  }
}

@end

@implementation RCTNendAdViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [RCTNADView new];
}

RCT_EXPORT_METHOD(loadAd:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RCTNADView *view = (RCTNADView *)viewRegistry[reactTag];
    if (view) {
      [view loadAd];
    }
  }];
}

RCT_EXPORT_METHOD(resume:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RCTNADView *view = (RCTNADView *)viewRegistry[reactTag];
    if (view) {
      [view.adView resume];
    }
  }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RCTNADView *view = (RCTNADView *)viewRegistry[reactTag];
    if (view) {
      [view.adView pause];
    }
  }];
}

RCT_EXPORT_VIEW_PROPERTY(spotId, NSString)
RCT_EXPORT_VIEW_PROPERTY(apiKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(adjustSize, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onAdLoaded, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdFailedToLoad, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClicked, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onInformationClicked, RCTBubblingEventBlock)

@end
