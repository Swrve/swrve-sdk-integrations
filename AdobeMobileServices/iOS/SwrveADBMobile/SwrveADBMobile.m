//
//  SwrveADMobile.m
//  Swrve ADMobile integration
//
//  Copyright (c) 2015 Swrve. All rights reserved.
//

#include <objc/runtime.h>
#import "SwrveADBMobile.h"
#import "SwrveADBMobile.h"
#import "SwrveSwizzleHelper.h"

typedef void (*ADBMobileTrackActionSignature)(__strong id,SEL,NSString*, NSDictionary*);
typedef void (*ADBMobileTrackStateSignature)(__strong id,SEL,NSString*, NSDictionary*);
typedef void (*ADBMobileTrackActionFromBackgroundSignature)(__strong id,SEL,NSString*, NSDictionary*);
typedef void (*ADBMobileSetPushIdentifierSignature)(__strong id,SEL,NSData*);

@interface SwrveADBMobile ()

@end

@implementation SwrveADBMobile

static ADBMobileTrackActionSignature originalTrackActionMethod;
static ADBMobileTrackStateSignature originalTrackStateMethod;
static ADBMobileTrackActionSignature originalTrackActionFromBackgroundMethod;
static ADBMobileSetPushIdentifierSignature originalSetPushIdentifierMethod;

+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey
{
    return [SwrveADBMobile initWithAppIDAndAdobeIntegration:swrveAppID apiKey:swrveAPIKey userID:nil];
}

+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID {
    return [SwrveADBMobile initWithAppIDAndAdobeIntegration:swrveAppID apiKey:swrveAPIKey userID:nil config:[[SwrveConfig alloc] init]];
}

+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey config:(SwrveConfig*)swrveConfig
{
    return [SwrveADBMobile initWithAppIDAndAdobeIntegration:swrveAppID apiKey:swrveAPIKey userID:nil config:swrveConfig];
}

+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig
{
    Class adbmobileClass = [ADBMobile class];
    SEL admobileTrackActionSelector = @selector(trackAction:data:);
    SEL admobileTrackStateSelector = @selector(trackState:data:);
    SEL admobileTrackActionFromBackgroundSelector = @selector(trackActionFromBackground:data:);
    SEL admobileSetPushIdentifierSelector = @selector(setPushIdentifier:);
    
    // Cast to actual method signature
    originalTrackActionMethod = (ADBMobileTrackActionSignature)[SwrveADBMobile swizzleClassMethod:admobileTrackActionSelector inClass:adbmobileClass withImplementationIn:[self class]];
    
    originalTrackStateMethod = (ADBMobileTrackStateSignature)[SwrveADBMobile swizzleClassMethod:admobileTrackStateSelector inClass:adbmobileClass withImplementationIn:[self class]];
    
    originalTrackActionFromBackgroundMethod = (ADBMobileTrackActionSignature)[SwrveADBMobile swizzleClassMethod:admobileTrackActionFromBackgroundSelector inClass:adbmobileClass withImplementationIn:[self class]];
    
    originalSetPushIdentifierMethod = (ADBMobileSetPushIdentifierSignature)[SwrveADBMobile swizzleClassMethod:admobileSetPushIdentifierSelector inClass:adbmobileClass withImplementationIn:[self class]];
    
    // Use the ADBMobile SDK tracking id as user id if not configured
    if (swrveUserID == nil) {
        swrveUserID = [ADBMobile trackingIdentifier];
    }
    
    return [Swrve sharedInstanceWithAppID:swrveAppID apiKey:swrveAPIKey userID:swrveUserID config:swrveConfig];
}

+ (IMP) swizzleClassMethod:(SEL)selector inClass:(Class)c withImplementationIn:(Class)c2;
{
    // Obtain meta classes
    c = object_getClass((id)c);
    c2 = object_getClass((id)c2);
    
    Method originalMethod = class_getInstanceMethod(c, selector);
    Method newMethod = class_getInstanceMethod(c2, selector);
    IMP oldImplementation = method_getImplementation(originalMethod);
    
    if (!oldImplementation) {
        class_addMethod(c, selector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
        return oldImplementation;
    }
    
    return NULL;
}

// ADMobile captured methods
+ (void) trackAction:(NSString *)action data:(NSDictionary *)data {
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        DebugLog(@"Error: Swrve Adobe Mobile SDK Integration only works if you are using the Swrve instance singleton.", nil);
    } else {
        [swrveInstance event:action payload:data];
    }
    
    // Call original method
    if(originalTrackActionMethod != NULL ) {
        SEL admobileTrackActionSelector = @selector(trackAction:data:);
        originalTrackActionMethod(nil, admobileTrackActionSelector, action, data);
    }
}

+ (void) trackState:(NSString *)action data:(NSDictionary *)data {
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        DebugLog(@"Error: Swrve Adobe Mobile SDK Integration only works if you are using the Swrve instance singleton.", nil);
    } else {
        [swrveInstance userUpdate:data];
    }
    
    // Call original method
    if(originalTrackStateMethod != NULL ) {
        SEL admobileTrackStateSelector = @selector(trackState:data:);
        originalTrackStateMethod(nil, admobileTrackStateSelector, action, data);
    }
}

+ (void) trackActionFromBackground:(NSString *)action data:(NSDictionary *)data {
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        DebugLog(@"Error: Swrve Adobe Mobile SDK Integration only works if you are using the Swrve instance singleton.", nil);
    } else {
        [swrveInstance event:action payload:data];
    }
    
    // Call original method
    if(originalTrackActionFromBackgroundMethod != NULL ) {
        SEL admobileTrackActionFromBackgroundSelector = @selector(trackActionFromBackground:data:);
        originalTrackActionFromBackgroundMethod(nil, admobileTrackActionFromBackgroundSelector, action, data);
    }
}

+ (void) setPushIdentifier:(NSData*)newDeviceToken {
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        DebugLog(@"Error: Swrve Adobe Mobile SDK Integration only works if you are using the Swrve instance singleton.", nil);
    } else {
        [swrveInstance.talk setDeviceToken:newDeviceToken];
    }
    
    // Call original method
    if(originalSetPushIdentifierMethod != NULL ) {
        SEL admobileSetPushIdentifierSelector = @selector(setPushIdentifier:);
        originalSetPushIdentifierMethod(nil, admobileSetPushIdentifierSelector, newDeviceToken);
    }
}

@end
