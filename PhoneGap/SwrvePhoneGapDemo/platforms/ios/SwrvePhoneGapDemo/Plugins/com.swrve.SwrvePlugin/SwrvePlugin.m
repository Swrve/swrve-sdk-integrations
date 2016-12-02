#import "SwrvePlugin.h"
#import <Cordova/CDV.h>
#import "Swrve.h"

#define SWRVE_WRAPPER_VERSION "1.1"

CDVViewController* globalViewController;

BOOL resourcesListenerReady;
BOOL mustCallResourcesListener;
BOOL pushNotificationListenerReady;
NSMutableArray* pushNotificationsQueued;

@implementation SwrvePlugin

+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions
{
    [SwrvePlugin initWithAppID:appId apiKey:apiKey config:nil viewController:viewController launchOptions:launchOptions];
}

+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey config:(SwrveConfig*)config viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions
{
    pushNotificationsQueued = [[NSMutableArray alloc] init];
    globalViewController = viewController;
    if (config == nil) {
        config = [[SwrveConfig alloc] init];
        config.pushEnabled = YES;
    }

    // Set a resource callback
    config.resourcesUpdatedCallback = ^() {
        if (resourcesListenerReady) {
            NSDictionary* userResources = [[[Swrve sharedInstance] getSwrveResourceManager] getResources];
            [SwrvePlugin resourcesListenerCall:userResources];
        } else {
            mustCallResourcesListener = YES;
        }
    };
    [Swrve sharedInstanceWithAppID:appId apiKey:apiKey config:config];

    // Tell the Swrve SDK your app was launched from a push notification
    NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        [SwrvePlugin processRemoteNotification:remoteNotification];
    }
    // Notify the Swrve JS plugin of the IAM custom button click
    [Swrve sharedInstance].talk.customButtonCallback = ^(NSString* action) {
        [SwrvePlugin evaluateString:[NSString stringWithFormat:@"if (window.swrveCustomButtonListener !== undefined) { window.swrveCustomButtonListener('%@'); }", action] onWebView:globalViewController.webView];
    };

    // Send the wrapper version at init
    [[Swrve sharedInstance] userUpdate:[[NSDictionary alloc] initWithObjectsAndKeys:@SWRVE_WRAPPER_VERSION, @"swrve.wrapper_version", nil]];
}

+ (void) evaluateString:(NSString*)jsString onWebView:(UIView*)webView
{
    if ([webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString waitUntilDone:NO];
    } else {
        [webView performSelectorOnMainThread:@selector(evaluateJavaScript:completionHandler:) withObject:jsString waitUntilDone:NO];
    }
}

+ (NSString*)base64Encode:(NSData*)data
{
    NSString* currentVersion = [[UIDevice currentDevice] systemVersion];
    if ([currentVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        return [data base64EncodedStringWithOptions:0];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [data base64Encoding];
#pragma clang diagnostic pop
}

+ (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState swrveState = [application applicationState];
    if (swrveState == UIApplicationStateInactive || swrveState == UIApplicationStateBackground) {
        [SwrvePlugin processRemoteNotification:userInfo];
    }
}

+ (void)notifySwrvePluginOfRemoteNotification:(NSString*)base64Json
{
    [SwrvePlugin evaluateString:[NSString stringWithFormat:@"if (window.swrveProcessPushNotification !== undefined) { window.swrveProcessPushNotification('%@'); }", base64Json] onWebView:globalViewController.webView];
}

+ (void)processRemoteNotification:(NSDictionary* )userInfo
{
    [[Swrve sharedInstance].talk pushNotificationReceived:userInfo];

    // Notify the Swrve JS plugin of this remote notification
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Could not serialize remote push notification payload: %@", error);
    } else {
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Json = [SwrvePlugin base64Encode:jsonData];
        if (pushNotificationListenerReady) {
            [SwrvePlugin notifySwrvePluginOfRemoteNotification:base64Json];
        } else {
            @synchronized(pushNotificationsQueued) {
                [pushNotificationsQueued addObject:base64Json];
            }
        }
    }
}

- (void)event:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* eventName = [command.arguments objectAtIndex:0];

    if (eventName != nil) {
        if ([command.arguments count] == 2) {
            NSDictionary* payload = [command.arguments objectAtIndex:1];
            [[Swrve sharedInstance] event:eventName payload:payload];
        } else {
            [[Swrve sharedInstance] event:eventName];
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Event name was null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)userUpdate:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* attributes = [command.arguments objectAtIndex:0];

    if (attributes != nil) {
        [[Swrve sharedInstance] userUpdate:attributes];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Attributes were null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)userUpdateDate:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if ([command.arguments count] == 2) {
        NSString* propertyName = [command.arguments objectAtIndex:0];
        NSString* propertyValueRaw = [command.arguments objectAtIndex:1];

        // Parse date coming in (for example "2016-12-02T15:39:47.608Z")
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

        NSDate* propertyValue = [dateFormatter dateFromString:propertyValueRaw];
        if (propertyValue != nil) {
            [[Swrve sharedInstance] userUpdate:propertyName withDate:propertyValue];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Could not parse date"];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not enough args"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)currencyGiven:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if ([command.arguments count] == 2) {
        NSString* currencyName = [command.arguments objectAtIndex:0];
        NSNumber* amount = [command.arguments objectAtIndex:1];

        [[Swrve sharedInstance] currencyGiven:currencyName givenAmount:[amount doubleValue]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not enough args"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)purchase:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if ([command.arguments count] == 4) {
        NSString* itemName = [command.arguments objectAtIndex:0];
        NSString* currencyName = [command.arguments objectAtIndex:1];
        NSNumber* quantity = [command.arguments objectAtIndex:2];
        NSNumber* cost = [command.arguments objectAtIndex:3];

        [[Swrve sharedInstance] purchaseItem:itemName currency:currencyName cost:[cost intValue] quantity:[quantity intValue]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not enough args"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)unvalidatedIap:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    if ([command.arguments count] == 4) {
        NSNumber* localCost = [command.arguments objectAtIndex:0];
        NSString* localCurrency = [command.arguments objectAtIndex:1];
        NSString* productId = [command.arguments objectAtIndex:2];
        NSNumber* quantity = [command.arguments objectAtIndex:3];

        [[Swrve sharedInstance] unvalidatedIap:nil localCost:[localCost doubleValue] localCurrency:localCurrency productId:productId productIdQuantity:[quantity intValue]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not enough args"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendEvents:(CDVInvokedUrlCommand *)command
{
    @try {
        [[Swrve sharedInstance] sendQueuedEvents];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    @catch ( NSException *e ) {
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
}

- (void)getUserResources:(CDVInvokedUrlCommand *)command
{
    NSDictionary* userResourcesDic = [[[Swrve sharedInstance] getSwrveResourceManager] getResources];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userResourcesDic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getUserResourcesDiff:(CDVInvokedUrlCommand *)command
{
    [[Swrve sharedInstance] getUserResourcesDiff:^(NSDictionary *oldResourcesValues, NSDictionary *newResourcesValues, NSString *resourcesAsJSON) {
        NSMutableDictionary* resourcesDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newResourcesValues, @"new", oldResourcesValues, @"old", nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resourcesDictionary];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)refreshCampaignsAndResources:(CDVInvokedUrlCommand *)command
{
    [[Swrve sharedInstance] refreshCampaignsAndResources];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)resourcesListenerReady:(CDVInvokedUrlCommand *)command
{
    resourcesListenerReady = YES;
    if (mustCallResourcesListener) {
        NSDictionary* userResources = [[[Swrve sharedInstance] getSwrveResourceManager] getResources];
        [SwrvePlugin resourcesListenerCall:userResources];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+(void)resourcesListenerCall:(NSDictionary*)userResources
{
    // Notify the Swrve JS plugin of the lates user resources
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userResources options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Could not serialize latest user resources: %@", error);
    } else {
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Json = [SwrvePlugin base64Encode:jsonData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SwrvePlugin evaluateString:[NSString stringWithFormat:@"if (window.swrveProcessResourcesUpdated !== undefined) { swrveProcessResourcesUpdated('%@'); }", base64Json] onWebView:globalViewController.webView];
        });
    }
}

- (void)pushNotificationListenerReady:(CDVInvokedUrlCommand *)command
{
    pushNotificationListenerReady = YES;
    // Send queued notifications, if any
    @synchronized(pushNotificationsQueued) {
        if ([pushNotificationsQueued count] > 0) {
            for(NSString* push64Payload in pushNotificationsQueued) {
                [SwrvePlugin notifySwrvePluginOfRemoteNotification:push64Payload];
            }
            [pushNotificationsQueued removeAllObjects];
        }
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
