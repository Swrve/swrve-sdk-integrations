#import "TestAppDelegate.h"
#import "Swrve.h"
#import "SwrvePlugin.h"

@implementation TestAppDelegate

-(void) setupSwrveWithLaunchOptions:(NSDictionary*)launchOptions
{
    // Point to local http server
    SwrveConfig* config = [[SwrveConfig alloc] init];
    config.pushEnabled = YES;
    config.eventsServer = @"http://localhost:8083";
    config.contentServer = @"http://localhost:8085";
    [SwrvePlugin initWithAppID:1111 apiKey:@"fake_api_key" config:config viewController:self.viewController launchOptions:launchOptions];
}

@end
