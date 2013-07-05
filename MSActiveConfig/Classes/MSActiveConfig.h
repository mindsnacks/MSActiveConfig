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
 * @discussion MSActiveConfig will post this notification the first time it successfully retrieves an
 * updated configuration from the server.
 * This allows clients of Active Config to hold certain behaviour until they know that the configuration
 * in Active Config is more recent than the one bundled with the app.
 * This notification is dispatched on the main queue.
 * @warning you should first check if `firstConfigDownloadFinished` is NO before registering to this,
 * if it's YES, this notification will never be posted.
 */
extern NSString *const MSActiveConfigFirstDownloadFinishedNotification;

/**
 * @discussion this notification is posted everytime a download finishes successfuly.
 * @note for performance reason, the `userInfo` of the notification doesn't contain the new
 * `configurationState`, just the user and meta (@see keys below)
 */
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotification;
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationUserIDKey; // NSNull if user ID was nil.
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationMetaKey;
// Boolean value with whether the downloaded configuration was set as the current or not
// It will be NO if it was a download request for a user that is no longer the active one.
extern NSString *const MSActiveConfigDownloadUpdateFinishedNotificationConfigurationIsCurrentKey;

/**
 * @class MSActiveConfig
 * @discussion this class is thread safe. You can add observers / request config from any thread/queue.
 */
@interface MSActiveConfig : NSObject

/**
 * @discussion designated initializer.
 * @param downloader (required) the object that will request the configuration.
 * @param store (optional) an object that will persist the settings.
 */
- (id)initWithConfigDownloader:(id<MSActiveConfigDownloader>)downloader
                   configStore:(id<MSActiveConfigStore>)store;

/**
 * @discussion changing the userID here also sets it in the config store.
 * Specify `nil` for the generic active config.
 * @abstract setting a new userID requests the last known config for that user
 * in the config store, and notifies the listeneres about the changes.
 */
@property (atomic, copy) NSString *currentUserID;

@property (nonatomic, readonly, strong) id<MSActiveConfigDownloader> configDownloader;
@property (nonatomic, readonly, strong) id<MSActiveConfigStore> configStore;

/**
 * @discussion you can check if active config has already downloaded a configuration for the first time.
 * This can be used to know if the configuration in active config is potentially out of date.
 * @see `MSActiveConfigFirstDownloadFinishedNotification`.
 */
@property (atomic, readonly, assign) BOOL firstConfigDownloadFinished;

/**
 * @discussion queues a request to download an updated version of the config with the currently set userID.
 */
- (void)downloadNewConfig;

/**
 * @discussion each interested component of the app can register themselves as listeners
 * to receive setting changes from active config.
 * This DOES NOT strong the listener, so you must unregister if the listener is being dealloc'ed.
 * @param listener (required) usually `self`. Must conform to `MSActiveConfigListener` protocol.
 * @param sectionName (required) the subset of the configuration they're interested in.
 */
- (void)registerListener:(id<MSActiveConfigListener>)listener
          forSectionName:(NSString *)sectionName;

- (void)removeListener:(id<MSActiveConfigListener>)listener
        forSectionName:(NSString *)sectionName;

/**
 * @discussion you may be interested in the current state of the configuration at some point, but not in getting updates.
 * You can use this method to retrieve an `MSActiveConfigSection` object for a certain section (refer to the configuration exchange format documentation).
 * @return the MSActiveConfigSection with the current values for the current user or `nil` if none is present.
 */
- (MSActiveConfigSection *)configSectionWithName:(NSString *)sectionName;

/**
 * @discussion simply calls `-configSectionWithName:` but allows to use the literals syntax.
 * @example `MSActiveConfigSection *section = self.activeConfig[@"sectionName"];`
 */
- (MSActiveConfigSection *)objectForKeyedSubscript:(NSString *)sectionName;

/**
 * @return the meta dictionary of the current configuation state.
 */
- (NSDictionary *)currentConfigurationMetaDictionary;

@end