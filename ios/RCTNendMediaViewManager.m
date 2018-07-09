//
//  RCTNendMediaViewManager.m
//  AwesomeProject
//

#import "RCTNendMediaViewManager.h"

#import <React/RCTView.h>
#import <React/RCTUIManager.h>

#import "RCTNendVideoNativeAd.h"

@import NendAd;

@interface RCTMediaView : RCTView <NADNativeVideoViewDelegate>

@property (nonatomic, strong) NADNativeVideoView *videoView;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackStarted;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackStopped;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackCompleted;
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackError;
@property (nonatomic, copy) RCTBubblingEventBlock onFullScreenOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onFullScreenClosed;

@end

@implementation RCTMediaView

- (instancetype)init
{
  self = [super init];
  if (self) {
    _videoView = [[NADNativeVideoView alloc] initWithFrame:CGRectZero];
    _videoView.translatesAutoresizingMaskIntoConstraints = NO;
    _videoView.delegate = self;
    [self addSubview:_videoView];
    [NSLayoutConstraint activateConstraints:@[[_videoView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
                                              [_videoView.topAnchor constraintEqualToAnchor:self.topAnchor],
                                              [_videoView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
                                              [_videoView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]]];
  }
  return self;
}

#pragma mark - NADNativeVideoViewDelegate

- (void)nadNativeVideoViewDidStartPlay:(NADNativeVideoView *)videoView
{
  if (self.onPlaybackStarted) {
    self.onPlaybackStarted(nil);
  }
}

- (void)nadNativeVideoViewDidStopPlay:(NADNativeVideoView *)videoView
{
  if (self.onPlaybackStopped) {
    self.onPlaybackStopped(nil);
  }
}

- (void)nadNativeVideoViewDidCompletePlay:(NADNativeVideoView *)videoView
{
  if (self.onPlaybackCompleted) {
    self.onPlaybackCompleted(nil);
  }
}

- (void)nadNativeVideoViewDidFailToPlay:(NADNativeVideoView *)videoView
{
  if (self.onPlaybackError) {
    self.onPlaybackError(nil);
  }
}

- (void)nadNativeVideoViewDidOpenFullScreen:(NADNativeVideoView *)videoView
{
  if (self.onFullScreenOpened) {
    self.onFullScreenOpened(nil);
  }
}

- (void)nadNativeVideoViewDidCloseFullScreen:(NADNativeVideoView *)videoView
{
  if (self.onFullScreenClosed) {
    self.onFullScreenClosed(nil);
  }
}

@end

#pragma mark -

@implementation RCTNendMediaViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [RCTMediaView new];
}

RCT_EXPORT_METHOD(setMedia:(nonnull NSNumber *)reactTag refId:(nonnull NSNumber *)refId)
{
  RCTNendVideoNativeAd *module = [self.bridge moduleForClass:[RCTNendVideoNativeAd class]];
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RCTMediaView *view = (RCTMediaView *)viewRegistry[reactTag];
    if (view && module) {
      NADNativeVideo *videoAd = [module getVideoAdWithRefernceId:refId.integerValue];
      if (videoAd) {
        view.videoView.videoAd = videoAd;
      }
    }
  }];
}

RCT_EXPORT_VIEW_PROPERTY(onPlaybackStarted, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackStopped, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackCompleted, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackError, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFullScreenOpened, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFullScreenClosed, RCTBubblingEventBlock)

@end
