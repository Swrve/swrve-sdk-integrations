#import "SwrveRESTClient.h"
#import "SwrveCommonConnectionDelegate.h"
#import "SwrveCommon.h"

@interface SwrveConnectionDelegate : SwrveCommonConnectionDelegate

@property(nonatomic, strong) SwrveRESTClient *restClient;

- (id)init:(SwrveRESTClient *)restClient completionHandler:(ConnectionCompletionHandler)handler;

@end

@implementation SwrveConnectionDelegate

@synthesize restClient;

- (id)init:(SwrveRESTClient *)_restClient completionHandler:(ConnectionCompletionHandler)_handler {
    self = [super init:_handler];
    if (self) {
        [self setRestClient:_restClient];
    }
    return self;
}

// Override default implementation and store the metricsString
- (void)addHttpPerformanceMetrics:(NSString *)metricsString {
    if (restClient) {
        [restClient addHttpPerformanceMetrics:metricsString];
    }
}

@end

@implementation SwrveRESTClient

@synthesize httpPerformanceMetrics;
@synthesize timeoutInterval;

- (id)initWithTimeoutInterval:(NSTimeInterval)timeoutInt {
    self = [super init];
    if (self) {
        [self setTimeoutInterval:timeoutInt];
    }
    return self;
}

- (void)sendHttpGETRequest:(NSURL *)url queryString:(NSString *)query {
    [self sendHttpGETRequest:url queryString:query completionHandler:nil];
}

- (void)sendHttpGETRequest:(NSURL *)url {
    [self sendHttpGETRequest:url completionHandler:nil];
}

- (void)sendHttpGETRequest:(NSURL *)baseUrl queryString:(NSString *)query completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    NSURL *url = [NSURL URLWithString:query relativeToURL:baseUrl];
    [self sendHttpGETRequest:url completionHandler:handler];
}

- (void)sendHttpGETRequest:(NSURL *)url completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval];
    if (handler == nil) {
        [request setHTTPMethod:@"HEAD"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    [self sendHttpRequest:request completionHandler:handler];
}

- (void)sendHttpPOSTRequest:(NSURL *)url jsonData:(NSData *)json {
    [self sendHttpPOSTRequest:url jsonData:json completionHandler:nil];
}

- (void)sendHttpPOSTRequest:(NSURL*)url jsonData:(NSData*)json completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:json];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long) [json length]] forHTTPHeaderField:@"Content-Length"];

    [self sendHttpRequest:request completionHandler:handler];
}

- (void)sendHttpRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    NSArray *allMetricsToSend;

    @synchronized ([self httpPerformanceMetrics]) {
        allMetricsToSend = [[self httpPerformanceMetrics] copy];
        [[self httpPerformanceMetrics] removeAllObjects];
    }

    if (allMetricsToSend != nil && [allMetricsToSend count] > 0) {
        NSString *fullHeader = [allMetricsToSend componentsJoinedByString:@";"];
        [request addValue:fullHeader forHTTPHeaderField:@"Swrve-Latency-Metrics"];
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(response, data, error);
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [task resume];
        });
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        SwrveConnectionDelegate *connectionDelegate = [[SwrveConnectionDelegate alloc] init:handler];
        [NSURLConnection connectionWithRequest:request delegate:connectionDelegate];
#pragma clang diagnostic pop
    }
}

- (void)addHttpPerformanceMetrics:(NSString *)metrics {
    @synchronized ([self httpPerformanceMetrics]) {
        [[self httpPerformanceMetrics] addObject:metrics];
    }
}

@end
