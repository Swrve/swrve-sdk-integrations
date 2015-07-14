//
//  AppDelegate.m
//  SwrveAdobeMobileServicesDemo
//
//  Copyright (c) 2015 Swrve. All rights reserved.
//

#import "AppDelegate.h"
#import "SwrveADBMobile.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialise the Swrve SDK using the SwrveADMobile class
    // NOTE: Call this before any calls to ADBMobile
    [SwrveADBMobile initWithAppIDAndAdobeIntegration:1 apiKey:@"your_api_key"];
    
    // Uncomment this lines to control how the event data is passed down to the Swrve SDK
    /*[SwrveADBMobile setEventCallback:^(NSString* action, NSDictionary* data) {
        // Example only!
        NSString* eventName = [action stringByAppendingString:@".swrve"];
        [[Swrve sharedInstance] event:eventName payload:data];
    }];*/
    
    // Uncomment this lines to control how the state data is passed down to the Swrve SDK
    /*[SwrveADBMobile setTrackStateCallback:^(NSString* action, NSDictionary* data) {
        // Example only!
        [[Swrve sharedInstance] userUpdate:data];
    }];*/
    
    [ADBMobile collectLifecycleData];
    
    // The following calls will be intercepted by Swrve
    [ADBMobile trackAction:@"myapp.ActionName" data:nil];
    [ADBMobile trackState:@"Login Screen" data:nil];
    [ADBMobile trackActionFromBackground:@"myapp.ActionName" data:nil];
    // NOTE: The device token will be intercepted in the method [ADBMobile setPushIdentifier]
    
    return YES;
}

@end
