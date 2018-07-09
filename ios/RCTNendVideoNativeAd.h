//
//  RCTNendVideoNativeAd.h
//  AwesomeProject
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@class NADNativeVideo;

@interface RCTNendVideoNativeAd : RCTEventEmitter <RCTBridgeModule>

- (NADNativeVideo * _Nullable)getVideoAdWithRefernceId:(NSInteger)referenceId;

@end
