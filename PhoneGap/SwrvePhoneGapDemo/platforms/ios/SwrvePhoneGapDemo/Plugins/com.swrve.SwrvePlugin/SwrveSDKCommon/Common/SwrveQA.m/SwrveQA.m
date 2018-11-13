#import "SwrveQA.h"
#import "SwrveCommon.h"
#import <sys/time.h>
#import "SwrveLocalStorage.h"
#import "SwrveProfileManager.h"
#import "SwrveSignatureProtectedFile.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SwrveQA ()

@property(nonatomic) NSString *apiKey;
@property(nonatomic) long appID;
@property(nonatomic) NSString *userID;
@property(nonatomic) NSString *baseURL;
@property(nonatomic) NSString *appVersion;
@property(nonatomic) NSNumber *deviceID;
@property(nonatomic) NSString *sessionToken;

@end

@implementation SwrveQA

static NSString *const LOG_TYPE = @"log_type";
static NSString *const LOG_SOURCE = @"log_source";
static NSString *const LOG_SOURCE_LOCATION_SDK = @"location-sdk";
static NSString *const LOG_SOURCE_GEO_SDK = @"geo-sdk";
static NSString *const LOG_DETAILS = @"log_details";

#pragma mark Properties

@synthesize isQALogging = _isQALogging;
@synthesize apiKey = _apiKey;
@synthesize appID = _appID;
@synthesize userID = _userID;
@synthesize baseURL = _baseURL;
@synthesize appVersion = _appVersion;
@synthesize deviceID = _deviceID;
@synthesize sessionToken = _sessionToken;
@synthesize restClient;

#pragma mark Init

static SwrveQA *shared = nil;
static dispatch_once_t onceToken;

+ (id)sharedInstance {
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

#pragma mark Helpers

+ (void)updateQAUser:(NSDictionary *)jsonQa {
    [[SwrveQA sharedInstance] updateQAUser:jsonQa];
}

- (void)updateQAUser:(NSDictionary *)jsonQa {

    self.isQALogging = [[jsonQa objectForKey:@"logging"] boolValue];
    [SwrveLocalStorage saveQaUser:jsonQa];
    self.apiKey = [SwrveCommon sharedInstance].apiKey;
    self.baseURL = [SwrveCommon sharedInstance].eventsServer;
    self.deviceID = [SwrveCommon sharedInstance].deviceId;
    self.appID = [SwrveCommon sharedInstance].appID;
    self.appVersion = [SwrveCommon sharedInstance].appVersion;
    self.userID = [SwrveCommon sharedInstance].userID;


    if (self.restClient == nil) {
        self.restClient = [[SwrveRESTClient alloc] initWithTimeoutInterval:60];
    }
}

- (NSString *)createSessionToken {

    if (self.sessionToken != nil) return self.sessionToken;

    // Get the time since the epoch in seconds
    struct timeval time;
    gettimeofday(&time, NULL);
    const long startTime = time.tv_sec;

    SwrveProfileManager *swrveProfileManager = [[SwrveProfileManager alloc] init];
    NSString *sessionToken = [swrveProfileManager sessionTokenFromAppId:self.appID
                                                                 apiKey:self.apiKey
                                                                 userID:self.userID
                                                              startTime:startTime];

    self.sessionToken = sessionToken;

    return sessionToken;
}

static id ObjectOrNull(id object) {
    return object ? object : [NSNull null];
}

- (NSString *)getTimeFormatted {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];

    NSDate *now = [NSDate date];
    return [dateFormatter stringFromDate:now];
}

// TODO method below is copied from Swrve.m but there should only be one of these as its supposed to be synchronized access
- (NSInteger)nextEventSequenceNumber {
    NSInteger seqno;
    @synchronized (self) {
        // Defaults to 0 if this value is not available
        NSString *seqNumKey = [[SwrveCommon sharedInstance].userID stringByAppendingString:@"swrve_event_seqnum"];
        seqno = [SwrveLocalStorage seqNumWithCustomKey:seqNumKey];
        seqno += 1;
        [SwrveLocalStorage saveSeqNum:seqno withCustomKey:seqNumKey];
    }

    return seqno;
}

- (NSMutableDictionary *)createJSONForEvent:(NSMutableDictionary *)event {

    [event setValue:@"qa_log_event" forKey:@"type"];
    [event setValue:[self getTimeFormatted] forKey:@"time"];
    [event setValue:[NSNumber numberWithInteger:[self nextEventSequenceNumber]] forKey:@"seqnum"];

    NSArray *dataArray = @[event];
    NSMutableDictionary *jsonPacket = [[NSMutableDictionary alloc] init];
    [jsonPacket setValue:self.userID forKey:@"user"];
    [jsonPacket setValue:self.deviceID forKey:@"short_device_id"];
    [jsonPacket setValue:[NSNumber numberWithInt:SWRVE_VERSION] forKey:@"version"];
    [jsonPacket setValue:NullableNSString(self.appVersion) forKey:@"app_version"];
    [jsonPacket setValue:[self createSessionToken] forKey:@"session_token"];
    [jsonPacket setValue:dataArray forKey:@"data"];

    return jsonPacket;
}

+ (void)makeRequest:(NSMutableDictionary *)jsonBody {

    [[SwrveQA sharedInstance] makeRequest:jsonBody];
}

- (void)makeRequest:(NSMutableDictionary *)jsonBody {

    if (jsonBody == nil) return;

    NSMutableDictionary *newBody = [self createJSONForEvent:jsonBody];

    NSURL *baseURL = [NSURL URLWithString:self.baseURL];
    NSURL *requestURL = [NSURL URLWithString:@"/1/batch" relativeToURL:baseURL];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newBody options:0 error:nil];

    // Convert to string for logging
    if (jsonData) {
        NSString *json_string = nil;
        json_string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DebugLog(@"QaUser URL: %@", requestURL);
        DebugLog(@"QaUser Body: %@", json_string);
    }

    [self.restClient sendHttpPOSTRequest:requestURL
                                jsonData:jsonData
                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           if (error) {
                               DebugLog(@"QA Error: %@", error);
                           } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                               DebugLog(@"QA response was not a HTTP response: %@", response);
                           } else {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               long status = [httpResponse statusCode];
                               NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               DebugLog(@"HTTP Send to QA Log %ld", status);

                               if (status != 200) {
#pragma unused(responseBody)
                                   DebugLog(@"HTTP Error %ld while doing Talk QA", status);
                                   DebugLog(@"  %@", responseBody);
                               }
                           }
                       }];
}

#pragma mark Geo Logs

+ (void)geoCampaignTriggered:(NSArray *)campaigns
              fromGeoPlaceId:(NSString *)geoplaceId
               andGeofenceId:(NSString *)geofenceId
               andActionType:(NSString *)actionType {
    SwrveQA *swrveQA = [SwrveQA sharedInstance];
    if (!swrveQA || ![swrveQA isQALogging] || campaigns == nil || [campaigns count] == 0) {
        return;
    }
    NSMutableDictionary *qaLog = [swrveQA geoCampaignTriggered:campaigns fromGeoPlaceId:geoplaceId andGeofenceId:geofenceId andActionType:actionType];
    [swrveQA makeRequest:qaLog];
}

- (NSMutableDictionary *)geoCampaignTriggered:(NSArray *)campaigns
                               fromGeoPlaceId:(NSString *)geoplaceId
                                andGeofenceId:(NSString *)geofenceId
                                andActionType:(NSString *)actionType {
    NSMutableDictionary *qaLog = [@{LOG_TYPE: @"geo-campaign-triggered", LOG_SOURCE: LOG_SOURCE_GEO_SDK} mutableCopy];
    NSDictionary *logDetails = @{
            @"geoplace_id": @([geoplaceId longLongValue]),
            @"geofence_id": @([geofenceId longLongValue]),
            @"action_type": ObjectOrNull(actionType),
            @"campaigns": ObjectOrNull(campaigns)
    };
    [qaLog setValue:logDetails forKey:LOG_DETAILS];
    return qaLog;
}

+ (void)geoCampaignsDownloaded:(NSArray *)campaigns
                fromGeoPlaceId:(NSString *)geoplaceId
                 andGeofenceId:(NSString *)geofenceId
                 andActionType:(NSString *)actionType {
    SwrveQA *swrveQA = [SwrveQA sharedInstance];
    if (!swrveQA || ![swrveQA isQALogging] || campaigns == nil) {
        return;
    }
    NSMutableDictionary *qaLog = [swrveQA geoCampaignsDownloaded:campaigns withGeoPlaceId:geoplaceId andGeofenceId:geofenceId andActionType:actionType];
    [swrveQA makeRequest:qaLog];
}

- (NSMutableDictionary *)geoCampaignsDownloaded:(NSArray *)campaigns
                                 withGeoPlaceId:(NSString *)geoplaceId
                                  andGeofenceId:(NSString *)geofenceId
                                  andActionType:(NSString *)actionType{
    NSMutableDictionary *qaLog = [@{LOG_TYPE: @"geo-campaigns-downloaded", LOG_SOURCE: LOG_SOURCE_GEO_SDK} mutableCopy];
    NSDictionary *logDetails = @{
            @"geoplace_id": @([geoplaceId longLongValue]),
            @"geofence_id": @([geofenceId longLongValue]),
            @"action_type": ObjectOrNull(actionType),
            @"campaigns": ObjectOrNull(campaigns)
    };
    [qaLog setValue:logDetails forKey:LOG_DETAILS];
    return qaLog;
}

#pragma mark Location Logs

+ (NSMutableDictionary *)locationCampaignTriggered:(NSArray *)campaigns {

    return [[SwrveQA sharedInstance] locationCampaignTriggered:campaigns];
}

- (NSMutableDictionary *)locationCampaignTriggered:(NSArray *)campaigns {

    if (![[SwrveQA sharedInstance] isQALogging] || campaigns == nil) {return nil;}

    NSMutableDictionary *qaLog = [@{LOG_TYPE: @"location-campaign-triggered", LOG_SOURCE: LOG_SOURCE_LOCATION_SDK} mutableCopy];
    NSDictionary *logDetails = @{@"campaigns": ObjectOrNull(campaigns)};
    [qaLog setValue:logDetails forKey:LOG_DETAILS];
    return qaLog;
}

- (NSMutableDictionary *)cachedLocationCampaigns {

    NSMutableDictionary *campaignsDic = [NSMutableDictionary new];

    UInt64 installTime = [SwrveLocalStorage installTimeForUserId:self.userID];
    NSString *signatureKey = [NSString stringWithFormat:@"%@%llu", self.apiKey, installTime];

    SwrveSignatureProtectedFile *locationCampaignFile = [[SwrveSignatureProtectedFile alloc] protectedFileType:SWRVE_LOCATION_FILE
                                                                                                        userID:self.userID
                                                                                                  signatureKey:signatureKey
                                                                                                 errorDelegate:nil];
    NSData *data = [locationCampaignFile readFromFile];
    if (data != nil) {
        campaignsDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }

    return campaignsDic;
}

+ (NSMutableDictionary *)locationCampaignDownloaded {

    NSMutableDictionary *campaignsDic = [[SwrveQA sharedInstance] cachedLocationCampaigns];

    return [[SwrveQA sharedInstance] locationCampaignDownloaded:campaignsDic];
}

- (NSMutableDictionary *)locationCampaignDownloaded:(NSDictionary *)campaignsDic {

    if (!self.isQALogging) {return nil;}

    NSMutableDictionary *qaLog = [@{LOG_TYPE: @"location-campaigns-downloaded", LOG_SOURCE: LOG_SOURCE_LOCATION_SDK} mutableCopy];
    NSMutableArray *campaignArray = [NSMutableArray new];

    for (NSString *campaignID in campaignsDic) {

        NSDictionary *dic = campaignsDic[campaignID];

        DebugLog(@"Value: %@ for key: %@", dic, campaignID);

        NSDictionary *message = [dic objectForKey:@"message"];
        NSNumber *variantID = [message objectForKey:@"id"];

        NSDictionary *campInfo = @{@"id": ObjectOrNull(campaignID),
                @"variant_id": ObjectOrNull(variantID)
        };

        [campaignArray addObject:campInfo];
    }

    NSDictionary *logDetails = @{@"campaigns": ObjectOrNull(campaignArray)};
    [qaLog setValue:logDetails forKey:LOG_DETAILS];
    return qaLog;
}

+ (NSMutableDictionary *)locationCampaignEngagedID:(NSString *)campaignID variantID:(NSNumber *)variantID plotID:(NSString *)plotID payload:(NSDictionary *)payload {

    return [[SwrveQA sharedInstance] locationCampaignEngagedID:campaignID variantID:variantID plotID:plotID payload:payload];
}

- (NSMutableDictionary *)locationCampaignEngagedID:(NSString *)campaignID variantID:(NSNumber *)variantID plotID:(NSString *)plotID payload:(NSDictionary *)payload {

    if (!self.isQALogging) {return nil;}

    NSMutableDictionary *qaLog = [@{LOG_TYPE: @"location-campaign-engaged", LOG_SOURCE: LOG_SOURCE_LOCATION_SDK} mutableCopy];

    NSDictionary *logDetails = @{@"plot_campaign_id": ObjectOrNull(plotID),
            @"campaign_id": ObjectOrNull(campaignID),
            @"variant_id": ObjectOrNull(variantID),
            @"variant_payload": ObjectOrNull(payload)};

    [qaLog setValue:logDetails forKey:LOG_DETAILS];
    return qaLog;
}


@end
