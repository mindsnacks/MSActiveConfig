//
//  MSActiveConfig.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/26/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfigSection.h"
#import "MSActiveConfigListener.h"

@protocol MSActiveConfigDownloader;
@protocol MSActiveConfigListener;
@protocol MSActiveConfigStore;

/**
 `MSActiveConfig` is the public interface to the dynamic configuration.
 It provides methods to retrieve the current configuration at any time, or to register an object to 
 receive notifications whenever the configuration changes.
 
 ## Threading Notes
 `MSActiveConfig` is thread safe. You can add observers / request config from any thread/queue.
 */

@interface MSActiveConfig : NSObject

///----------------------------
/// @name Initialization
///----------------------------

/**
 Designated initializer.
 @param downloader (required) The object that will request the configuration. Must conform to `MSActiveConfigDownloader`.
 @param store (optional) An object that will persist the settings. Must conform to `MSActiveConfigStore`.
 */
- (id)initWithConfigDownloader:(id<MSActiveConfigDownloader>)downloader
                   configStore:(id<MSActiveConfigStore>)store;

///----------------------------
/// @name User ID Support
///----------------------------

/**
 The ID for the currently active user in your application. This can be used to provide different configurations to different users. Using `nil` is valid to refer to a generic configuration.
 @discussion Changing the `currentUserID` here causes `MSActiveConfig` to load the last known configuration for that user
 and notifies the listeneres about the changes.
 */
@property (atomic, copy) NSString *currentUserID;

/**
 The object in charge of downloading updates of the configuration.
 */
@property (nonatomic, readonly, strong) id<MSActiveConfigDownloader> configDownloader;

/**
 The object in charge of persisting and providing persisted configuration.
 */
@property (nonatomic, readonly, strong) id<MSActiveConfigStore> configStore;

///----------------------------
/// @name Configuration Download
///----------------------------

/**
 You can check if active config has ever downloaded a configuration from its downloader for the first time
 since the app was installed.
 @discussion This can be used to know if the configuration in active config is potentially out of date, and in that case,
 delay certain actions until that first download finishes, listening to the `MSActiveConfigFirstDownloadFinishedNotification` notification.
 */
@property (atomic, readonly, assign) BOOL firstConfigDownloadFinished;

/**
 Queues a request to download an updated version of the config with the current `currentUserID`.
 @abstract This method is never invoked automatically internally. You must decide when to call it from outside of this class
 to try to keep the configuration as updated as possible for all the users.
 */
- (void)downloadNewConfig;

///----------------------------
/// @name Listening for Changes
///----------------------------

/**
 You can register an object as a listener to receive setting changes from active config.
 @param listener (required) Must conform to `MSActiveConfigListener` protocol.
 @param sectionName (required) The subset of the configuration they're interested in.
 @note Refer to the Configuration Exchange Format documentation to understand the different parts of the configuration document.
 */
- (void)registerListener:(id<MSActiveConfigListener>)listener
          forSectionName:(NSString *)sectionName;

/**
 Registering a listener doesn't cause `MSActiveConfig` to retain it, so you must remove it using this method before it's deallocated.
 @param listener (required) Must conform to `MSActiveConfigListener` protocol.
 @param sectionName (required) The sectionName the listener was registered with.
 */
- (void)removeListener:(id<MSActiveConfigListener>)listener
        forSectionName:(NSString *)sectionName;

///----------------------------
/// @name Retrieving Configuration
///----------------------------

/**
 You may be interested in the current state of the configuration at some point, but not in getting updates.
 You can use this method to retrieve an `MSActiveConfigSection` object for a certain section 
 @note Refer to the Configuration Exchange Format documentation to understand the different parts of the configuration document.
 @return The `MSActiveConfigSection` with the current values for the current user or `nil` if none is present.
 */
- (MSActiveConfigSection *)configSectionWithName:(NSString *)sectionName;

/**
 Simply calls `-configSectionWithName:` but allows to use the literals syntax.
 */
- (MSActiveConfigSection *)objectForKeyedSubscript:(NSString *)sectionName;

/**
 The meta dictionary of the current configuation state.
 @note Refer to the Configuration Exchange Format documentation to understand the different parts of the configuration document.
 */
- (NSDictionary *)currentConfigurationMetaDictionary;

@end

///----------------
/// @name Notifications
///----------------

/**
 MSActiveConfig will post this notification the first time it successfully retrieves an
 updated configuration from the server.
 This allows clients of Active Config to hold certain behaviour until they know that the configuration
 in Active Config is more recent than the one bundled with the app.
 This notification is dispatched on the main queue.
 @warning you should first check if `firstConfigDownloadFinished` is NO before registering to this,
 if it's YES, this notification will never be posted.
 */
extern NSString *const MSActiveConfigFirstDownloadFinishedNotification;

/**
 @discussion this notification is posted everytime a download finishes successfuly.
 @note for performance reason, the `userInfo` of the notification doesn't contain the new
 `configurationState`, just the user (@see `MSActiveConfigDownloadUpdateFinishedNotificationUserIDKey`)
 and meta (@see `MSActiveConfigDownloadUpdateFinishedNotificationMetaKey`)
 */
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotification;
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationUserIDKey; // NSNull if user ID was nil.
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationMetaKey;

/**
 Boolean value with whether the downloaded configuration was set as the current or not
 It will be NO if it was a download request for a user that is no longer the active one.
 */
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationConfigurationIsCurrentKey;