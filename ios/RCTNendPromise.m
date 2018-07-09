//
//  RCTNendPromise.m
//  AwesomeProject
//

#import "RCTNendPromise.h"

@implementation RCTNendPromise

- (instancetype)initWithResolveBlock:(RCTPromiseResolveBlock)resolve rejectBlock:(RCTPromiseRejectBlock)reject
{
  self = [super init];
  if (self) {
    _resolve = [resolve copy];
    _reject = [reject copy];
  }
  return self;
}

@end
