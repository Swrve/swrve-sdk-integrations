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
    
    [ADBMobile collectLifecycleData];
    
    // The following calls will be intercepted by Swrve
    [ADBMobile trackAction:@"myapp.ActionName" data:nil];
    [ADBMobile trackState:@"Login Screen" data:nil];
    [ADBMobile trackActionFromBackground:@"myapp.ActionName" data:nil];
    // NOTE: The device token will be intercepted in the method [ADBMobile setPushIdentifier]
    
    return YES;
}

@end
