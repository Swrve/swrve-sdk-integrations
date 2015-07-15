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

#import "SwrveMessageFormat.h"

// Enumerates the possible types of action that can be associated with tapping a message button.
typedef enum {
    kSwrveActionDismiss,    // Cancel the message display
    kSwrveActionCustom,     // Handle the custom action string associated with the button
    kSwrveActionInstall     // Go to the url specified in the button’s action string
} SwrveActionType;

typedef void (^SwrveMessageResult)(SwrveActionType type, NSString* action, NSInteger appId);

@class SwrveMessageController;
@class SwrveCampaign;
@class SwrveButton;

@interface SwrveMessage : NSObject

@property (nonatomic, unsafe_unretained) SwrveCampaign* campaign; // Reference to parent campaign
@property (nonatomic, retain)            NSNumber* messageID;     // Identifies the message in a campaign
@property (nonatomic, retain)            NSString* name;          // The name of the message
@property (nonatomic, retain)            NSNumber* priority;      // The priority of the message
@property (nonatomic, retain)            NSString* createdAt;     // The date the message was created
@property (nonatomic, retain)            NSString* createdBy;     // The Swrve Dashboard user who created the message
@property (nonatomic, retain)            NSArray*  formats;       // An array of SwrveMessageFormat objects

+(SwrveMessage*)fromJSON:(NSDictionary*)json forCampaign:(SwrveCampaign*)campaign forController:(SwrveMessageController*)controller;

-(SwrveMessage*)updateWithJSON:(NSDictionary*)json
                 forCampaign:(SwrveCampaign*)campaign
                 forController:(SwrveMessageController*)controller;

-(SwrveMessageFormat*)getBestFormatFor:(UIInterfaceOrientation)orientation;

-(void)download;

-(BOOL)isDownloaded:(NSSet*)assets;

-(BOOL)supportsOrientation:(UIInterfaceOrientation)orientation;

-(void)wasShownToUser;

@end
