//
//  MSSecondViewController.m
//  MSActiveConfig-SampleApp
//
//  Created by Javier Soto on 7/6/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSSampleViewController.h"

#import "MSActiveConfigManager.h"
#import <MSActiveConfig/MSActiveConfig.h>
#import "Constants.h"

@interface MSSampleViewController () <MSActiveConfigListener>
{
    MSActiveConfig *_activeConfig;
}

@property (weak, nonatomic) IBOutlet UIView *rectangleView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end

@implementation MSSampleViewController

- (id)init
{
    if ((self = [super init]))
    {
        self.title = @"Display";

        _activeConfig = [MSActiveConfigManager defaultInstance].activeConfig;

        [_activeConfig registerListener:self
                         forSectionName:MSSampleActiveConfigViewConfigurationSectionName];
    }

    return self;
}

- (void)dealloc
{
    [_activeConfig removeListener:self
                   forSectionName:MSSampleActiveConfigViewConfigurationSectionName];
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setViewPropertiesWithConfigSection:_activeConfig[MSSampleActiveConfigViewConfigurationSectionName]];
}

#pragma mark - Active Config

- (void)setViewPropertiesWithConfigSection:(MSActiveConfigSection *)configSection
{
    NSDictionary *viewBackgroundColorDictionary = [configSection dictionaryForKey:@"ViewBackgroundColor"];
    const CGFloat redColorComponent = [viewBackgroundColorDictionary[@"red"] floatValue];
    const CGFloat greenColorComponent = [viewBackgroundColorDictionary[@"green"] floatValue];
    const CGFloat blueColorComponent = [viewBackgroundColorDictionary[@"blue"] floatValue];

    self.rectangleView.backgroundColor = [UIColor colorWithRed:redColorComponent
                                                         green:greenColorComponent
                                                          blue:blueColorComponent
                                                         alpha:1.0f];

    NSString *labelText = [configSection stringForKey:@"LabelText"];
    self.label.text = labelText;

    const BOOL buttonEnabled = [configSection boolForKey:@"ButtonEnabled"];
    self.switchButton.enabled = buttonEnabled;
}

- (void)activeConfig:(MSActiveConfig *)activeConfig
didReceiveConfigSection:(MSActiveConfigSection *)configSection
      forSectionName:(NSString *)sectionName
{
    [self setViewPropertiesWithConfigSection:configSection];
}

@end
