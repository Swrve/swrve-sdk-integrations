/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  SwrvePhoneGapDemo
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

#import <SwrveSDK/Swrve.h>
#import "SwrvePlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    
    // SWRVE CHANGES
    [self setupSwrveWithLaunchOptions:launchOptions];
    // END OF CHANGES
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// SWRVE CHANGES
-(void) setupSwrveWithLaunchOptions:(NSDictionary*)launchOptions
{
    SwrveConfig* config = [[SwrveConfig alloc] init];
    config.pushEnabled = true;
    [SwrvePlugin initWithAppID:1030 apiKey:@"SwrveDevApple" config:config viewController:self.viewController launchOptions:launchOptions];
}

#ifndef DISABLE_PUSH_NOTIFICATIONS
-(void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [SwrvePlugin application:application didReceiveRemoteNotification:userInfo];
}
#endif
// END OF CHANGES

@end
