#import "TestAppDelegate.h"
#import <SwrveSDK/Swrve.h>
#import "SwrvePlugin.h"

@implementation TestAppDelegate

-(void) setupSwrveWithLaunchOptions:(NSDictionary*)launchOptions
{
    // Point to local http server
    SwrveConfig* config = [[SwrveConfig alloc] init];
    config.eventsServer = @"http://localhost:8083";
    config.contentServer = @"http://localhost:8085";
    [SwrvePlugin initWithAppID:1 apiKey:@"api_key" config:config viewController:self.viewController launchOptions:launchOptions];
}

@end
