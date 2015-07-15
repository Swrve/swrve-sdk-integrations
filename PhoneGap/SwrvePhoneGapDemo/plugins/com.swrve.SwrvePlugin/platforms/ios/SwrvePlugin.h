#import <Cordova/CDV.h>

@interface SwrvePlugin : CDVPlugin

//- (void)init:(CDVInvokedUrlCommand*)command;
- (void)event:(CDVInvokedUrlCommand*)command;
- (void)userUpdate:(CDVInvokedUrlCommand*)command;
- (void)currencyGiven:(CDVInvokedUrlCommand*)command;
- (void)purchase:(CDVInvokedUrlCommand*)command;
- (void)iap:(CDVInvokedUrlCommand*)command;
- (void)onPause:(CDVInvokedUrlCommand*)command;
- (void)onResume:(CDVInvokedUrlCommand*)command;
- (void)flushEvents:(CDVInvokedUrlCommand*)command;
- (void)getUserResources:(CDVInvokedUrlCommand*)command;
- (void)getUserResourcesDiff:(CDVInvokedUrlCommand*)command;

@end