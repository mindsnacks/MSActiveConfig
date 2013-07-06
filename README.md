# MSActiveConfig
Remote configuration and A/B Testing framework for iOS.

[![Build Status](https://travis-ci.org/mindsnacks/MSActiveConfig.png?branch=master)](https://travis-ci.org/mindsnacks/MSActiveConfig)

## MSActiveConfig at a glance
One of the big challenges when making iOS apps is a consequence of the fact that pushing an app update takes a long time. Sometimes we want to be able to change something in one of our apps remotely as quickly as possible.

```objc
const BOOL isThisFeatureEnabled = [activeConfig[@"AppFeatures"] boolForKey:@"SomeFeatureEnabled"];
```

with this one-liner, `MSActiveConfig` would tell us if that particular feature has been enabled by us, but we can also react to changes on the configuration in real time:

```objc
[activeConfig registerListener:self
        		forSectionName:@"AppFeatures"];

- (void)activeConfig:(MSActiveConfig *)activeConfig
didReceiveConfigSection:(MSActiveConfigSection *)configSection
        forSectionName:(NSString *)sectionName
{
	[self changeFeatureEnabledStatus:configSection[@"SomeFeatureEnabled"]];
}
```

## Use cases
- Enabling and disabling features. This allows you to test features with only a subset of users before you roll it out to everyone, or to control the load that feature creates on on your backend, for example.
- Delaying making decisions after submitting the app. E.g.: *how often should this request happen?*, *How many times should this be retried?* With Active Config you no longer need to know the answer to those questions before you send your app to Apple, since you can change those values later easily.
- **A/B Testing!** If you can serve a configuration to your users, you can serve different configurations depending on who that user is. See more below.

### A/B Testing
The A/B Testing frameworks out there give most of the responsibility to the app: they assume the app is going to know all the possible values that you are going to want to test for a specific feature. This is incredibly restrictive, since it will force you to update your app to try new values. Active Config encourages you to leave the knowledge on the backend, giving your more control.

For example, if you were to A/B test some text on some part of your app, traditional A/B test frameworks would tell the app to choose option A, or option B. This way, the app must know before hand what those strings are. With Active Config, you would put the string inside the configuration, so you can change them at any point.

## Installation
### Using [CocoaPods](http://cocoapods.org/):
- Add `pod 'MSActiveConfig', '~> 1.0.0'` to your `Podfile`.
- You're done!

### Using submodules:
`git submodule add git@github.com:mindsnacks/MSActiveConfig.git <path/to/your/submodule>`

There are two ways you can integrate `MSActiveConfig` into your project:
- If you already have a workspace or don't mind creating one:

	- Add the `MSActiveConfig.xcodeproj` file into your project by dragging and dropping it.
	- Select your project on Xcode, and then your target and navigate to "Build Phases".
	- Tap on the "+" button on "Target Dependencies" and add `MSActiveConfig`.
	- Tap on the "+" button on "Link Binary with Libraries" and select `libMSActiveConfig.a`.
- By simply adding the source files inside `MSActiveConfig/Classes` into your project and compiling them with the rest of your source.

## Usage
Start by importing `MSActiveConfig.h`.
A typical app would have one `MSActiveConfig` object that you create like this:

```objc
id<MSActiveConfigDownloader> configDownloader = ...
id<MSActiveConfigStore> configStore = ...

MSActiveConfig *activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:configDownloader
																	configStore:configStore];
```

*For a complete code snippet on how to instantiate the `MSActiveConfig` object, [check the wiki](https://github.com/mindsnacks/MSActiveConfig/wiki/MSActiveConfig-Instantiation).*

### `MSActiveConfigDownloader`

A class must conform to this protocol to allow `MSActiveConfig` to retrieve updates from the network. The given class needs to implement this method.

```objc
- (NSDictionary *)requestActiveConfigForUserWithID:(NSString *)userID
                                             error:(NSError **)error;
```

For most applications, the provided **`MSJSONURLRequestActiveConfigDownloader`** class will suffice, it allows you to create a downloader object like this:

```objc
downloader = [[MSJSONURLRequestActiveConfigDownloader alloc] initWithCreateRequestBlock:^NSURLRequest *(NSString *userID) {
	return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myserver.com/activeconfig/user/%@", userID]]];
}];
```

*Note: `MSActiveConfig` will never start a download on its own, you must use the public method `-downloadNewConfig` to tell it to download.*

### `MSActiveConfigStore`

This protocol defines a series of methods that allows `MSActiveConfig` to persist downloaded configuration to be able to retrieve it on subsequent app launches in order to always use the most up to date configuration.

```objc
- (MSActiveConfigConfigurationState *)lastKnownActiveConfigurationForUserID:(NSString *)userID;
- (void)persistConfiguration:(MSActiveConfigConfigurationState *)configuration forUserID:(NSString *)userID;
```

`MSActiveConfig` provides one implementation of this protocol that uses `NSUserDefault` as its backing store: **`MSUserDefaultsActiveConfigStore`**. This class also allows you to provide an initial or *bootstrapped* configuration that will be use until the app successfully downloads a more recent configuration from the server.

```objc
- (id)initWithInitialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;
```

### `MSActiveConfigConfigurationState`

This class represents a given configuration set that Active Config can use to provide setting values. It can be instantiated from an `NSDictionary` for example to create the initial configuration for `MSUserDefaultsActiveConfigStore` by parsing a JSON file in the app bundle.

### `MSActiveConfigSection`

This is the type of object that you get when you ask `MSActiveConfig` for configuration. It's a wrapper around all the setting keys and values in the specified *ConfigSection* *(See Configuration Exchange Format below)*. It has methods to retrieve a value expecting a specific type, and returns a form of nil in case the setting key isn't present or it has a different type.

## Configuration Exchange Format
`MSActiveConfig` is built to be extremely flexible. The only rules that you need to follow are imposed by the configuration exchange format that `MSActiveConfig` understands. The configuration is represented in a dictionary object that must look like this:

```json
{
    "meta":
    {
        "format_version_string": "1.0",
        "creation_time": "2012-08-20T19:36Z",
        "other_meta_key": "arbitrary objects with other relevant information"
    },
    "config_sections":
    {
        "ConfigSection1":
        {
            "settings":
            {
                "SettingKey1":
                {
                    "value": "This can be a a string, number, boolean, array or object"
                }
            }
        },
    }
}
```

When you ask `MSActiveConfig` to download an update of the configuration, it will expect a dictionary with this format. If the provided dictionary can't be parsed, the problem will be logged to the console and the configuration will be ignored.

### Meta
The meta section of the configuration must contain the format version (for future use) and the creation time (for debug purposes).
All other added values are optional but can be used to give context to the configuration.

For example, if you're using `MSActiveConfig` to do some kind of A/B Testing, you can add some information to the meta dictionary to later on identify what group of the test that user belongs to when sending events to your analytics service. You can access the meta dictionary in two ways:
- When a new configuration finishes downloading, `MSActiveConfig` posts an `NSNotification` (`MSActiveConfigDownloadUpdateFinishedNotification`) that contains the meta dictionary in one of the `userInfo` keys (`MSActiveConfigDownloadUpdateFinishedNotificationMetaKey`).
- At any time, by calling the `-currentConfigurationMetaDictionary` method on `MSActiveConfig`.

### Config Section
This is the top level group of settings. A section groups a series of settings that are relevant to a specific component of your app. When using the `-registerListener:forSectionName:` API, you can be notified when any of the settings of a section changes. They're represented with the `MSActiveConfigSection` class.

### Setting Key
This is a particular setting contained within a section. These are the ones that you'll ask `MSActiveConfigSection` for.

## User ID Support
`MSActiveConfig` provides APIs to allow you to have different configurations for different users on your app. This is designed for apps that allow you to log-out and log-in with a different user. If this is not your case, all these APIs allow you to simply use `nil` as a userID.

## Requirements
`MSActiveConfig` requires iOS6 or higher, but it would be easy to make it support iOS5 if you really need it for your project.

## License
`MSActiveConfig` is available under the MIT license. See the LICENSE file for more info.
