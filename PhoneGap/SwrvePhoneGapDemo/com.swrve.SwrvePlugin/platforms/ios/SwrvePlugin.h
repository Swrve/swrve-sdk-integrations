#import <Cordova/CDV.h>

@interface SwrvePlugin : CDVPlugin

- (void)event:(CDVInvokedUrlCommand*)command;
- (void)userUpdate:(CDVInvokedUrlCommand*)command;
- (void)currencyGiven:(CDVInvokedUrlCommand*)command;
- (void)purchase:(CDVInvokedUrlCommand*)command;
- (void)sendEvents:(CDVInvokedUrlCommand*)command;
- (void)getUserResources:(CDVInvokedUrlCommand*)command;
- (void)getUserResourcesDiff:(CDVInvokedUrlCommand*)command;

@end