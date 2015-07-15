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

#import "SwrveMessageViewController.h"

static NSString* const AUTOSHOW_AT_SESSION_START_TRIGGER = @"Swrve.Messages.showAtSessionStart";

@class SwrveMessage;
@class SwrveButton;
@class Swrve;

/**
 * A block that will be called when an install button in a message
 is pressed. Returning false stops the normal flow preventing
 Swrve to process the install action. Return true otherwise.
 */
typedef BOOL (^SwrveInstallButtonPressedCallback) (NSString* appStoreUrl);

/**
 * A block that will be called when a custom button in a message
 is pressed.
 */
typedef void (^SwrveCustomButtonPressedCallback) (NSString* action);

/*
 * Delegate used to control how messages are shown in your app.
 */
@protocol SwrveMessageDelegate <NSObject>

@optional

/*
 * Called when an event is raised by the Swrve Track SDK.  Look up a message
 * to display.  Return nil if no message should be displayed.  By default
 * the SwrveMessageController will search for messages with the provided
 * names.
 */
- (SwrveMessage*)findMessageForEvent:(NSString*) eventName withParameters:(NSDictionary *)parameters;

/*
 * Called when a message should be shown. Should show and react to the action
 * in the message.  By default the SwrveMessageController will display the
 * message as a modal dialog.  If an install action is returned by the dialog
 * it will direct the user to the app store.  If you have a custom action you
 * should create a custom delegate.
 */
- (void)showMessage:(SwrveMessage *)message;

/*
 * Called when the message will be shown to the user.  The message is shown in
 * a separate UIWindow.  This selector is called before that UIWindow is shown.
 */
- (void) messageWillBeShown:(SwrveMessageViewController *) viewController;

/*
 * Called when the message will be hidden from the user.  The message is shown
 * in a separate UIWindow.  This selector is called before that UIWindow is
 * hidden.
 */
- (void) messageWillBeHidden:(SwrveMessageViewController*) viewController;

/*
 * Called to animate the display of a message.  Implement this selector
 * to customize the display of the message.
 */
- (void) beginShowMessageAnimation:(SwrveMessageViewController*) viewController;

/*
 * Called to animate the hiding of a message.  Implement this selector to
 * customize the hiding of the message.  If you implement this you must call
 * [SwrveMessageController dismissMessageWindow] to dismiss the message window
 * after your animation is complete.
 */
- (void) beginHideMessageAnimation:(SwrveMessageViewController*) viewController;

@end

@interface SwrveMessageController : NSObject<SwrveMessageDelegate>

@property (nonatomic, retain) UIColor* backgroundColor;
@property (nonatomic, retain) NSArray* campaigns;
@property (nonatomic, assign) id <SwrveMessageDelegate> showMessageDelegate;
@property (nonatomic, copy)   SwrveCustomButtonPressedCallback customButtonCallback;
@property (nonatomic, copy)   SwrveInstallButtonPressedCallback installButtonCallback;
@property (nonatomic, retain) CATransition* showMessageTransition;
@property (nonatomic, retain) CATransition* hideMessageTransition;

// Initialization method. Requires a Swrve object.
- (id)initWithSwrve:(Swrve*)swrve;

// Matches the named event against corresponding messages using the rules in its
// downloaded campaigns. Returns a message, if one is found, otherwise nil.
- (SwrveMessage*)getMessageForEvent:(NSString *)event;

- (void)saveSettings;

// Call this if implementing a custom renderer and a message button was pressed by the user.
-(void)buttonWasPressedByUser:(SwrveButton*)button;

// Call this if implementing a customer renderer and a message has been shown to the user.
-(void)messageWasShownToUser:(SwrveMessage*)message;

- (NSString*)getAppStoreURLForGame:(long)game;
+(NSString*)getTimeFormatted:(NSDate*)date;
+(NSArray*)shuffled:(NSArray*)source;

// Returns a Swrve Talk compatible name for the event.
-(NSString*) getEventName:(NSDictionary*)eventParameters;

// Called when an event is raised by the Swrve Track SDK.  For internal use. Returns YES if a message was shown
-(BOOL)eventRaised:(NSDictionary*)event;

// Call this when you have a push notification device token.
- (void)setDeviceToken:(NSData*)deviceToken;

// Process push notification
- (void)pushNotificationReceived:(NSDictionary*)userInfo;

// Returns true if the current user is a qa user, false otherwise
- (BOOL)isQaUser;

// Creates a new fullscreen UIWindow, adds messageViewController to it and makes
// it visible.  If a message window is already displayed, nothing is done.
- (void) showMessageWindow:(UIViewController*) messageViewController;

// Dismisses the message if it is visible.  If the message window is not visible
// nothing is done.
- (void) dismissMessageWindow;

@end

