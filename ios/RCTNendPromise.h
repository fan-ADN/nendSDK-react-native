//
//  RCTNendPromise.h
//  AwesomeProject
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCTNendPromise : NSObject

@property (readonly, nonatomic, copy) RCTPromiseResolveBlock resolve;
@property (readonly, nonatomic, copy) RCTPromiseRejectBlock reject;

- (instancetype)initWithResolveBlock:(RCTPromiseResolveBlock)resolve rejectBlock:(RCTPromiseRejectBlock)reject;

@end
