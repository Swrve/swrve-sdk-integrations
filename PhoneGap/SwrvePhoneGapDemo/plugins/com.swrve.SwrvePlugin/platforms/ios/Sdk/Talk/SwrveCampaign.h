/*
 * SWRVE CONFIDENTIAL
 *
 * (c) Copyright 2010-2014 Swrve New Media, Inc. and its licensors.
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is and remains the property of Swrve
 * New Media, Inc or its licensors.  The intellectual property and technical
 * concepts contained herein are proprietary to Swrve New Media, Inc. or its
 * licensors and are protected by trade secret and/or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from Swrve.
 */

@class SwrveMessage;
@class SwrveButton;
@class SwrveMessageController;

@interface SwrveCampaign : NSObject

@property (atomic, retain)    NSArray*  messages;
@property (atomic)            NSUInteger next;
@property (atomic)            NSUInteger ID;
@property (atomic)            NSUInteger maxImpressions;
@property (atomic)            NSTimeInterval minDelayBetweenMsgs;
@property (atomic)            NSUInteger impressions;
@property (nonatomic, retain) NSDate* showMsgsAfterLaunch;        // Only show messages after this time.
@property (nonatomic, retain) NSDate* showMsgsAfterDelay;         // Only show messages after this time.
@property (nonatomic, retain) NSString* name;

-(id)initAtTime:(NSDate*)time;

-(BOOL)hasMessageForEvent:(NSString*)event;

-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time;
-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time
                       withReasons:(NSMutableDictionary*)campaignReasons;

+(BOOL)runningOnRetinaDevice;
-(void)incrementImpressions;
-(void)messageWasShownToUser:(SwrveMessage*)message;
-(NSDictionary*)campaignSettings;
-(void)loadTriggersFrom:(NSDictionary*)json;
-(void)loadRulesFrom:(NSDictionary*)json;
-(void)loadDatesFrom:(NSDictionary*)json;

@end
