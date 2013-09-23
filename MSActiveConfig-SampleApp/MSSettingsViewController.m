//
//  MSFirstViewController.m
//  MSActiveConfig-SampleApp
//
//  Created by Javier Soto on 7/6/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSSettingsViewController.h"

#import "Constants.h"

#import "MSActiveConfigManager.h"
#import <MSActiveConfig/MSActiveConfig.h>
#import <MSActiveConfig/MSActiveConfig+Private.h>

@interface MSSettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate, MSActiveConfigListener>
{
    MSActiveConfig *_activeConfig;
}

@property (weak, nonatomic) IBOutlet UIPickerView *userIDPickerView;
@property (weak, nonatomic) IBOutlet UITextView *activeConfigStateTextView;

@property (copy, nonatomic) NSArray *userIDs;

@end

@implementation MSSettingsViewController

- (id)init
{
    if ((self = [super init]))
    {
        self.title = @"Settings";

        self.userIDs = @[@"1", @"2", @"3"];

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateTextView];
}

- (void)updateTextView
{
    self.activeConfigStateTextView.text = [[MSActiveConfigManager defaultInstance].activeConfig.configDictionary description];
}

#pragma mark - MSActiveConfigListener

- (void)activeConfig:(MSActiveConfig *)activeConfig
didReceiveConfigSection:(MSActiveConfigSection *)configSection
      forSectionName:(NSString *)sectionName
{
    [self updateTextView];
}

#pragma mark - UIPickerViewDataSource and UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.userIDs.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *currentUserID = self.userIDs[row];

    _activeConfig.currentUserID = currentUserID;
    // On a real app you want something smarter to decide when to re-download:
    [_activeConfig downloadNewConfig];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.userIDs[row];
}

@end
