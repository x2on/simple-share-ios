//
//  SimpleFacebookConfiguration.h
//  simple-share
//
//  Created by  on 30.05.12.
//  Copyright 2012 Felix Schulze. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>

@interface SimpleFacebookConfiguration : NSObject

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *iOSAppId;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appDescription;
@property (nonatomic, strong) NSString *appUrl;
@property (nonatomic, strong) NSString *appIconUrl;

@end