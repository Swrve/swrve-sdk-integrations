#import "Swrve.h"
#if __has_include(<SwrveConversationSDK/SwrveConversationItemViewController.h>)
#import <SwrveConversationSDK/SwrveConversationItemViewController.h>
#else
#import "SwrveConversationItemViewController.h"
#endif

static NSString* const AUTOSHOW_AT_SESSION_START_TRIGGER = @"Swrve.Messages.showAtSessionStart";
const static int CAMPAIGN_VERSION            = 6;
const static int CAMPAIGN_RESPONSE_VERSION   = 2;

/*! In-app messages controller */
@interface SwrveMessageController ()

/*! Initialize the message controller.
 *
 * \param swrve Swrve SDK instance.
 * \returns Initialized message controller.
 */
- (id)initWithSwrve:(Swrve*)swrve;

/*! Save campaigns current state*/
-(void)saveCampaignsState;

/*! Ensure any currently displaying conversations are dismissed*/
-(void) cleanupConversationUI;

/*! Format the given time into POSIX time.
 *
 * \param date Date to format into text.
 * \returns Date formatted into a POSIX string.
 */
+(NSString*)formattedTime:(NSDate*)date;

/*! Shuffle the given array randomly.
 *
 \param source Array to be shuffled.
 \returns Copy of the array, now shuffled randomly.
 */
+(NSArray*)shuffled:(NSArray*)source;

/*! Called when an event is raised by the Swrve SDK.
 *
 * \param event Event triggered.
 * \returns YES if an in-app message was shown.
 */
-(BOOL)eventRaised:(NSDictionary*)event;

/*! Check if the user is a QA user.
 *
 * \returns TRUE if the current user is a QA user.
 */
- (BOOL)isQaUser;

/*! Determine if the conversation filters are supporter at this moment.
 *
 * \param filters Filters we need to support to display the campaign.
 * \returns nil if all devices are supported or the name of the filter that is not supported.
 */
-(NSString*) supportsDeviceFilters:(NSArray*)filters;

/*! Called when the app became active */
-(void) appDidBecomeActive;

/*! The device token was updated and we should update the QA user */
-(void) deviceTokenUpdated;

/*! A push notification was received, notify the QA user */
- (void) pushNotificationReceived:(NSDictionary*)userInfo;


#if TARGET_OS_TV /** only have for tvOS **/
-(NSArray*) messageCenterCampaignsForTvOS;
#endif

#pragma mark Properties

@property (nonatomic) Swrve*  analyticsSDK;
@property (nonatomic, retain) SwrveConversationItemViewController* swrveConversationItemViewController;

#pragma mark -

@end

