//
//  SimpleGoogleChromeShare.m
//  simple-share-demo
//
//  Created by  on 14.02.2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "SimpleGoogleChromeShare.h"
#import "OpenInChromeController.h"

@implementation SimpleGoogleChromeShare {
    OpenInChromeController *openInChromeController;
}

- (id)init {
    self = [super init];
    if (self) {
        openInChromeController = [[OpenInChromeController alloc] init];
    }
    return self;
}

- (BOOL) canOpenInChrome {
    return [openInChromeController isChromeInstalled];
}

- (BOOL) openInChrome:(NSURL *)theUrl {
    return [openInChromeController openInChrome:theUrl];
}

- (BOOL) openInChrome:(NSURL *)theUrl callbackUrl:(NSURL *)theCallbackUrl {
    return [openInChromeController openInChrome:theUrl withCallbackURL:theCallbackUrl createNewTab:NO];
}


@end