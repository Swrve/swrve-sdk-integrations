#import <XCTest/XCTest.h>
#import "HTTPServer.h"
#import <SwrveSDK/Swrve.h>
#import "SwrvePlugin.h"

#import "AppDelegate.h"
#import "TestHTTPConnection.h"
#import "TestHTTPResponse.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface PhoneGapWrapper_Tests : XCTestCase {
    HTTPServer* httpEventServer;
    HTTPServer* httpContentServer;
    NSMutableArray* lastEventBatches;
    AppDelegate* appDelegate;
    CDVViewController* controller;
}
@end

@implementation PhoneGapWrapper_Tests

- (void)setUp
{
    [super setUp];
    
    // Setup local servers
    NSString *rootPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UnitTestServer"];
    httpEventServer = [[HTTPServer alloc] init];
    [httpEventServer setConnectionClass:[TestHTTPConnection class]];
    [httpEventServer setPort:8085];
    [httpEventServer setDocumentRoot:rootPath];
    NSError *error = nil;
    if(![httpEventServer start:&error]) {
        NSLog(@"Error starting event HTTP Server: %@", error);
    }
    
    httpContentServer = [[HTTPServer alloc] init];
    [httpContentServer setConnectionClass:[TestHTTPConnection class]];
    [httpContentServer setPort:8083];
    [httpContentServer setDocumentRoot:rootPath];
    if(![httpContentServer start:&error]) {
        NSLog(@"Error starting content HTTP Server: %@", error);
    }
    
    // Emulate user resources and campaigns endpoints
    NSURL* path = [[NSBundle bundleForClass:[PhoneGapWrapper_Tests class]] URLForResource:@"test_campaigns_and_resources" withExtension:@"json"];
    NSString* testresourcesAndCampaigns = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:nil];
    [TestHTTPConnection setHandler:@"api/1/user_resources_and_campaigns" handler:^NSObject<HTTPResponse>*(NSString* path, HTTPMessage *request) {
        return [[TestHTTPResponse alloc] initWithString:testresourcesAndCampaigns];
    }];
    [TestHTTPConnection setHandler:@"api/1/user_resources_diff" handler:^NSObject<HTTPResponse>*(NSString* path, HTTPMessage *request) {
        NSString* testResourcesDiff = @"[{ \"uid\": \"house\", \"diff\": { \"cost\": { \"old\": \"550\", \"new\": \"666\" }}}]";
        return [[TestHTTPResponse alloc] initWithString:testResourcesDiff];
    }];
    
    // Emulate event endpoint
    lastEventBatches = [[NSMutableArray alloc] init];
    [TestHTTPConnection setHandler:@"1/batch" handler:^NSObject<HTTPResponse>*(NSString* path, HTTPMessage *request) {
        NSString* batchBody = [[NSString alloc] initWithData:request.body encoding:NSUTF8StringEncoding];
        [lastEventBatches addObject:batchBody];
        return [[TestHTTPResponse alloc] initWithData:[@"OK" dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // Image in CDN
    [TestHTTPConnection setHandler:@"/cdn/" handler:^NSObject<HTTPResponse>*(NSString* urlPath, HTTPMessage *request) {
        NSString* fileName = [urlPath stringByReplacingOccurrencesOfString:@"/cdn/" withString:@""];
        NSURL* url = [[NSBundle bundleForClass:[PhoneGapWrapper_Tests class]] URLForResource:fileName withExtension:nil];
        TestHTTPResponse* response;
        if (url != nil) {
            NSData *imageData = [[NSData alloc]initWithContentsOfURL:url options:0 error:nil];
            response = [[TestHTTPResponse alloc] initWithData:imageData];
            response.contentType = @"image/png";
        } else {
            response = [[TestHTTPResponse alloc] initWithData:[@"404 Not Found" dataUsingEncoding:NSUTF8StringEncoding]];
            response.responseStatus = 404;
        }
        return response;
    }];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    controller = appDelegate.viewController;
}

- (void)tearDown
{
    [super tearDown];
    
    if (httpEventServer != nil) {
        [httpEventServer stop];
        httpEventServer = nil;
    }
    
    if (httpContentServer != nil) {
        [httpContentServer stop];
        httpContentServer = nil;
    }
}

- (void) waitForPhoneGapAppToLoad
{
    // Wait 10s for the view to load
    NSDate *timerStart = [NSDate date];
    NSString* domButton = nil;
    for (int i = 0; i < 10; i++) {
        domButton = [self runJS:@"document.querySelector('.swrve-event-button').toString();"];
        if (domButton != nil && ![domButton isEqualToString:@""]) {
            break;
        } else {
            // Wait a bit more...
            NSDate* runUntil = [NSDate dateWithTimeInterval:i sinceDate:timerStart];
            [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
        }
    }
    XCTAssert(domButton != nil && ![domButton isEqualToString:@""]);
}

- (NSString*) runJS:(NSString*)js
{
    return [controller.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void) waitForSeconds:(int)seconds
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeInterval:seconds sinceDate:[NSDate date]]];
}

- (void)testEvents
{
    [self waitForPhoneGapAppToLoad];
    // Send any previous events now
    [self runJS:@"window.plugins.swrve.sendEvents(undefined, undefined);"];
    [self waitForSeconds:1];
    
    // Send all instrumented events
    [self runJS:@"window.plugins.swrve.event(\"levelup\", undefined, undefined);"];
    [self runJS:@"window.plugins.swrve.event(\"leveldown\", {\"armor\":\"disabled\"}, undefined, undefined);"];
    [self runJS:@"window.plugins.swrve.userUpdate({\"phonegap\":\"TRUE\"}, undefined, undefined);"];
    [self runJS:@"window.plugins.swrve.currencyGiven(\"Gold\", 20, undefined, undefined);"];
    [self runJS:@"window.plugins.swrve.purchase(\"sword\", \"Gold\", 2, 15, undefined, undefined);"];
    [self runJS:@"window.plugins.swrve.sendEvents(undefined, undefined);"];
    // Give 10 seconds for the events to go through
    [self waitForSeconds:10];
    
    // Check event data
    NSString* lastBatchJSON = [lastEventBatches lastObject];
    NSDictionary *lastBatch = [NSJSONSerialization JSONObjectWithData:[lastBatchJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSArray* lastEvents = [lastBatch objectForKey:@"data"];
    
    typedef BOOL (^EventChecker)(NSDictionary* event);
    NSMutableArray *eventChecks = [[NSMutableArray alloc] init];
    // Check for event
    [eventChecks addObject:^BOOL(NSDictionary* event) {
        return [[event objectForKey:@"name"] isEqualToString:@"levelup"]
        && [[event objectForKey:@"payload"] count] == 0;
    }];
    // Check for event with payload
    [eventChecks addObject:^BOOL(NSDictionary* event) {
        return [[event objectForKey:@"name"] isEqualToString:@"leveldown"]
        && [[[event objectForKey:@"payload"] objectForKey:@"armor"] isEqualToString:@"disabled"];
    }];
    // Check for user update event
    [eventChecks addObject:^BOOL(NSDictionary* event) {
        return [[event objectForKey:@"type"] isEqualToString:@"user"]
        && [[[event objectForKey:@"attributes"] objectForKey:@"phonegap"] isEqualToString:@"TRUE"];
    }];
    // Check for currency given event
    [eventChecks addObject:^BOOL(NSDictionary* event) {
        return [[event objectForKey:@"type"] isEqualToString:@"currency_given"]
        && [[event objectForKey:@"given_amount"] longValue] == 20
        && [[event objectForKey:@"given_currency"] isEqualToString:@"Gold"];
    }];
    // Check for purchase event
    [eventChecks addObject:^BOOL(NSDictionary* event) {
        return [[event objectForKey:@"type"] isEqualToString:@"purchase"]
        && [[event objectForKey:@"quantity"] longValue] == 2
        && [[event objectForKey:@"cost"] longValue] == 15
        && [[event objectForKey:@"currency"] isEqualToString:@"Gold"]
        && [[event objectForKey:@"item"] isEqualToString:@"sword"];
    }];

    for(EventChecker check in eventChecks) {
        BOOL checkPasses = NO;
        for (NSDictionary* event in lastEvents) {
            if (check(event)) {
                checkPasses = YES;
                break;
            }
        }
        if (!checkPasses) {
            XCTFail(@"Event defined in check not found");
        }
    }
}

- (void)testUserResourcesAndResourcesDiff
{
    [self waitForPhoneGapAppToLoad];

    // Call resources methods
    [self runJS:
     @"window.plugins.swrve.getUserResourcesDiff(function(resourcesDiff) {"
        @"window.testResourcesDiff = resourcesDiff;"
     @"}, function () {});"];
    
    [self runJS:
     @"window.plugins.swrve.getUserResources(function(resources) {"
        @"window.testResources = resources;"
     @"}, function () {});"];
    
    // Give 10 seconds for the response to be received by the Javascript callbacks
    [self waitForSeconds:10];
    
    // Check user resources obtained through the plugin
    NSString* userResourcesObtainedJSON = [self runJS:@"JSON.stringify(window.testResources)"];
    NSDictionary *userResourcesObtained = [NSJSONSerialization JSONObjectWithData:[userResourcesObtainedJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    XCTAssertEqual([[[userResourcesObtained objectForKey:@"house"] objectForKey:@"cost"] integerValue], 999);

    // Check user resources diff obtained through the plugin
    NSString* userResourcesDiffObtainedJSON = [self runJS:@"JSON.stringify(window.testResourcesDiff)"];
    NSDictionary *userResourcesDiffObtained = [NSJSONSerialization JSONObjectWithData:[userResourcesDiffObtainedJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    XCTAssertEqual([[[[userResourcesDiffObtained objectForKey:@"new"] objectForKey:@"house"] objectForKey:@"cost"] integerValue], 666);
    XCTAssertEqual([[[[userResourcesDiffObtained objectForKey:@"old"] objectForKey:@"house"] objectForKey:@"cost"] integerValue], 550);
}

- (void)testCustomButtonListener
{
    [self waitForPhoneGapAppToLoad];
    
    // Display IAM to check that the custom button listener works
    // Inject javascript listeners
    [self runJS:@"window.swrveCustomButtonListener = function(action) { window.testCustomAction = action; };"];

    UIViewController* viewController = nil;
    int retries = 5;
    do {
        // Launch IAM campaign
        [self runJS:@"window.plugins.swrve.event(\"campaign_trigger\", undefined, undefined);"];
        [self waitForSeconds:5];
        // Detect view controller
        viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
    } while(retries-- > 0 && (viewController == nil || [viewController class] != [SwrveMessageViewController class]));
    
    SwrveMessageViewController* iamController = (SwrveMessageViewController*)viewController;
    UIView* messageView = [iamController.view.subviews firstObject];
    UIButton* customButton = [messageView.subviews firstObject];
    [customButton sendActionsForControlEvents: UIControlEventTouchUpInside];
    [self waitForSeconds:5];
    
    NSString* listenerCustomAction = [self runJS:@"window.testCustomAction"];
    XCTAssert([listenerCustomAction isEqualToString:@"custom_action_from_server"]);
}

- (void)testCustomPushPayloadListener
{
    [self waitForPhoneGapAppToLoad];

    // Send fake remote notification to check that the custom push payload listener works
    // Inject javascript listeners
    [self runJS:@"window.swrvePushNotificationListener = function(payload) { window.testPushPayload = payload; };"];
    [self waitForSeconds:1];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1234], @"_p", @"custom", @"custom_payload", nil];
    // Mock state of the app
    UIApplication* backgroundStateApp = mock([UIApplication class]);
    [given([backgroundStateApp applicationState]) willReturnInt:UIApplicationStateBackground];
    [appDelegate application:backgroundStateApp didReceiveRemoteNotification:userInfo];
    [self waitForSeconds:5];
    
    NSString* listenerPushPayloadPayload = [self runJS:@"window.testPushPayload.custom_payload"];
    XCTAssert([listenerPushPayloadPayload isEqualToString:@"custom"]);
}

@end