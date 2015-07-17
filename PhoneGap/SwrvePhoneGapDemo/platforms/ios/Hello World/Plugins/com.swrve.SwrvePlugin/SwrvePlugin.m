#import "SwrvePlugin.h"

#import <Cordova/CDV.h>
#import <SwrveSDK/Swrve.h>

@implementation SwrvePlugin

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
        NSNumber* cost = [command.arguments objectAtIndex:2];
        
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
