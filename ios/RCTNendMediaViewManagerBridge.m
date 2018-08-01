//
//  RCTNendMediaViewManagerBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(RCTNendMediaViewManager, RCTViewManager)

RCT_EXTERN_METHOD(setMedia:(nonnull NSNumber *)reactTag refId:(NSInteger)refId);

RCT_EXPORT_VIEW_PROPERTY(onPlaybackStarted, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackStopped, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackCompleted, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackError, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFullScreenOpened, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFullScreenClosed, RCTBubblingEventBlock)

@end
