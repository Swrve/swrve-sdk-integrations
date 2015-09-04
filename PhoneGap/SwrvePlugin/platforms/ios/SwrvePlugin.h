#import <Cordova/CDV.h>
#import <SwrveSDK/Swrve.h>

@interface SwrvePlugin : CDVPlugin

+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions;
+ (void)initWithAppID:(int)appId apiKey:(NSString*)apiKey config:(SwrveConfig*)config viewController:(CDVViewController*)viewController launchOptions:(NSDictionary*)launchOptions;
+ (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)event:(CDVInvokedUrlCommand*)command;
- (void)userUpdate:(CDVInvokedUrlCommand*)command;
- (void)currencyGiven:(CDVInvokedUrlCommand*)command;
- (void)purchase:(CDVInvokedUrlCommand*)command;
- (void)unvalidatedIap:(CDVInvokedUrlCommand *)command;
- (void)sendEvents:(CDVInvokedUrlCommand*)command;
- (void)getUserResources:(CDVInvokedUrlCommand*)command;
- (void)getUserResourcesDiff:(CDVInvokedUrlCommand*)command;

@end