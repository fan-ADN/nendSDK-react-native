//
//  RCTNendUserFeatureBridge.m
//  AwesomeProject
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(NendUserFeature, RCTNendUserFeature, NSObject)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(create);
RCT_EXTERN_METHOD(setGender:(NSInteger)refId gender:(NSInteger)gender);
RCT_EXTERN_METHOD(setAge:(NSInteger)refId age:(NSInteger)age);
RCT_EXTERN_METHOD(setBirthday:(NSInteger)refId year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day);
RCT_EXTERN_METHOD(addCustomStringValue:(NSInteger)refId key:(NSString *)key value:(NSString *)value);
RCT_EXTERN_METHOD(addCustomBooleanValue:(NSInteger)refId key:(NSString *)key value:(BOOL)value);
RCT_EXTERN_METHOD(addCustomIntegerValue:(NSInteger)refId key:(NSString *)key value:(NSInteger)value);
RCT_EXTERN_METHOD(addCustomDoubleValue:(NSInteger)refId key:(NSString *)key value:(double)value);
RCT_EXTERN_METHOD(destroy:(NSInteger)refId);

@end
