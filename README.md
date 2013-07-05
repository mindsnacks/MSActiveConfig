# MSActiveConfig
Remote configuration and A/B Testing framework for iOS.

# Unit Test Status
[![Build Status](https://travis-ci.org/MindSnacks/MSActiveConfig.png?branch=master)](https://travis-ci.org/MindSnacks/MSActiveConfig)

## MSActiveConfig at a glance
One of the big challenges of making iOS apps is a consequence of the fact that pushing an app update takes a long time. In real life, sometimes we want to be able to change something in one of our apps remotely as quickly as possible *(See examples of usage for Active Config below)*

```objc
const BOOL isThisFeatureEnabled = [activeConfig[kSectionKey] boolForKey:kFeatureEnabledSettingKey];
```

### Examples of Usage
- Enabling and disabling features. This allows you to test out features that you're not sure about, or to enable them only for a subset of users to control the load on your backend, for example.
- Delaying making decisions after submitting the app. For example: how often should this request happen? How many times should this be retried? With Active Config you no longer need to know the answer to those questions to be able to submit, since you can change those values later easily.
- **A/B Testing!** If you can serve a configuration to your users, you can serve different configurations depending on who that user is. See more below.

### A/B Testing
The A/B Testing frameworks out there give most of the responsibility to the app: they assume the app is going to know all the possible values that you are going to want to test for a specific feature. This is incredibly restrictive, since it will force you to update your app to try new values. Active Config encourages you to leave the knowledge on the backend, giving your more control.

For example, if you were to A/B test some text on some part of your app, traditional A/B test frameworks would tell the app to choose option A, or option B. This way, the app must know before hand what those strings are. With Active Config, you would put the string inside the configuration, so you can change them at any point.
