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

#import "SwrveMessage.h"

@class SwrveMessage;

@interface SwrveMessageViewController : UIViewController

@property (nonatomic, retain) SwrveMessage*      message;   // The message to render.
@property (nonatomic, copy)   SwrveMessageResult block;     // The custom code to execute when a button is tapped or a message is dismissed by a user.

-(IBAction)onButtonPressed:(id)sender;

@end
