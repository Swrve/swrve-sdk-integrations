//
//  SwrveADMobile.h
//  Swrve ADMobile integration
//
//  Copyright (c) 2015 Swrve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Swrve.h"
#import "ADBMobile.h"

@interface SwrveADBMobile : NSObject

/*! Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *  It also injects into the Adobe Mobile SDK to ease integration.
 *
 * The default user ID is a random UUID. The userID is cached in the
 * default settings of the app and recalled the next time you initialize the
 * app. This means the ID for the user will stay consistent for as long as the
 * user has your app installed on the device.
 *
 * \param swrveAppID The App ID for your app supplied by Swrve.
 * \param swrveAPIKey The secret token for your app supplied by Swrve.
 * \returns An initialized Swrve object.
 */
+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey;

/*! Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *  It also injects into the Adobe Mobile SDK to ease integration.
 *
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. The default user ID is a random UUID.
 *
 * \param swrveAppID The App ID for your app supplied by Swrve.
 * \param swrveAPIKey The secret token for your app supplied by Swrve.
 * \param swrveUserID The unique user id for your application.
 * \returns An initialized Swrve object.
 */
+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID;

/*! Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *  It also injects into the Adobe Mobile SDK to ease integration.
 *
 * Takes a SwrveConfig object that can be used to change default settings.
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. The default user ID is a random UUID.
 *
 * \param swrveAppID The App ID for your app supplied by Swrve.
 * \param swrveAPIKey The secret token for your app supplied by Swrve.
 * \param swrveConfig The swrve configuration object used to override default settings.
 * \returns An initialized Swrve object.
 */
+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey config:(SwrveConfig*)swrveConfig;

/*! Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *  It also injects into the Adobe Mobile SDK to ease integration.
 *
 * Takes a SwrveConfig object that can be used to change default settings.
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. The default user ID is a random UUID.
 *
 * \param swrveAppID The App ID for your app supplied by Swrve.
 * \param swrveAPIKey The secret token for your app supplied by Swrve.
 * \param swrveUserID The unique user id for your application.
 * \param swrveConfig The swrve configuration object used to override default settings.
 * \returns An initialized Swrve object.
 */
+(Swrve*) initWithAppIDAndAdobeIntegration:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig;

@end
