#import "SwrvePlugin.h"
#import <Cordova/CDV.h>

#import "Swrve.h"

@implementation SwrvePlugin

/*- (void)init:(CDVInvokedUrlCommand*)command
{
    @try {
        NSNumber* appId = [self getNSNumberParam:command.arguments at:0];
        NSString* apiKey = [self getNSStringParam:command.arguments at:1];
        
        // Initialize Swrve
        [Swrve sharedInstanceWithAppID:[appId intValue] apiKey:apiKey];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    @catch ( NSException *e ) {
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
}*/

- (void)event:(CDVInvokedUrlCommand*)command
{
    @try {
        NSString* eventName = [self getNSStringParam:command.arguments at:0];
        [[Swrve sharedInstance] event:eventName];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    @catch ( NSException *e ) {
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
}

- (void)userUpdate:(CDVInvokedUrlCommand*)command
{
}

- (void)currencyGiven:(CDVInvokedUrlCommand*)command
{
}

- (void)purchase:(CDVInvokedUrlCommand*)command
{
}

- (void)iap:(CDVInvokedUrlCommand*)command
{
}

- (void)onPause:(CDVInvokedUrlCommand*)command
{
}

- (void)onResume:(CDVInvokedUrlCommand*)command
{
}

- (void)flushEvents:(CDVInvokedUrlCommand *)command
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
    @try {
        NSDictionary* userResourcesDic = [[[Swrve sharedInstance] getSwrveResourceManager] getResources];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userResourcesDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    @catch ( NSException *e ) {
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
}

- (void)getUserResourcesDiff:(CDVInvokedUrlCommand *)command
{
}

// Utilities
-(NSString*) getNSStringParam:(NSArray*)array at:(int)index
{
    if ([[array objectAtIndex:index] isKindOfClass:[NSString class]]) {
        return (NSString*)[array objectAtIndex:index];
    }
    
    @throw([NSException exceptionWithName:@"Invalid plugin parameter" reason:@"Could not find NSString parameter" userInfo:nil]);
}

-(NSNumber*) getNSNumberParam:(NSArray*)array at:(int)index
{
    if ([[array objectAtIndex:index] isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)[array objectAtIndex:index];
    }
    
    @throw([NSException exceptionWithName:@"Invalid plugin parameter" reason:@"Could not find NSNumber parameter" userInfo:nil]);
}

@end
