#import "AppDelegate.h"
#import "Swrve.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SwrveConfig* config = [[SwrveConfig alloc] init];
    config.resourcesUpdatedCallback = ^() {
        // New campaigns are available
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SwrveUserResourcesUpdated" object:self];
    };
    
    //FIXME: Add wour App ID (instead of -1) and your API Key (instead of <API_KEY>) here.
    [Swrve sharedInstanceWithAppID:-1 apiKey:@"<API_KEY>" config:config launchOptions:launchOptions];
    return YES;
}

@end
