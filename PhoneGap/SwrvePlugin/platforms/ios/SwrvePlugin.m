#import "SwrvePlugin.h"
#import "AppDelegate.h"

#import <Cordova/CDV.h>
#import <SwrveSDK/Swrve.h>

static CDVViewController* globalViewController;

@implementation SwrvePlugin

+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions
{
    [SwrvePlugin initWithAppID:appId apiKey:apiKey config:nil viewController:viewController launchOptions:launchOptions];
}

+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey config:(SwrveConfig*)config viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions
{
    globalViewController = viewController;
    if (config == nil) {
        config = [[SwrveConfig alloc] init];
        config.pushEnabled = YES;
    }
    
    [Swrve sharedInstanceWithAppID:appId apiKey:apiKey config:config];

    // Tell the Swrve SDK your app was launched from a push notification
    NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        [SwrvePlugin notifySwrvePluginOfRemoteNotification:remoteNotification];
    }
    // Notify the Swrve JS plugin of the IAM custom button click
    [Swrve sharedInstance].talk.customButtonCallback = ^(NSString* action) {
        [globalViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.swrveCustomButtonListener('%@')", action]];
    };
}

+ (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState swrveState = [application applicationState];
    if (swrveState == UIApplicationStateInactive || swrveState == UIApplicationStateBackground) {
        [SwrvePlugin notifySwrvePluginOfRemoteNotification:userInfo];
    }
}

+ (void)notifySwrvePluginOfRemoteNotification:(NSDictionary* )userInfo
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
        NSString *base64Json = [jsonData cdv_base64EncodedString];
        [globalViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.swrveProcessPushNotification('%@')", base64Json]];
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

@end
