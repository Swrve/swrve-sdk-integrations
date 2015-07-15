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

#import "SwrveMessageController.h"

@class SwrveMessageController;

@interface SwrveButton : NSObject

@property (nonatomic, retain)            NSString* image;                     // The cached path of the button image on disk
@property (nonatomic, retain)            NSString* actionString;              // The custom action string for the button
@property (nonatomic, unsafe_unretained) SwrveMessageController* controller;  // Reference to parent message controller
@property (nonatomic, unsafe_unretained) SwrveMessage* message;               // Reference to parent message
@property (atomic)                       CGPoint center;                      // The position of the button
@property (atomic)                       CGSize  size;                        // The size of the button
@property (atomic)                       long messageID;                      // The message identifier associated with this button
@property (atomic)                       long appID;                          // The id of the target installation game
@property (atomic)                       SwrveActionType actionType;          // The action associated with this button

-(UIButton*)createButtonWithOrientation:(UIInterfaceOrientation)orientation
                            andDelegate:(id)delegate
                            andSelector:(SEL)selector
                               andScale:(float)scale
                             andCenterX:(float)cx
                             andCenterY:(float)cy;


-(void)wasPressedByUser;

@end
