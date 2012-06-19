//
//  SimpleFacebookConfiguration.m
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

#import "SimpleFacebookConfiguration.h"
#import "JSONKit.h"

@implementation SimpleFacebookConfiguration
@synthesize appId;
@synthesize iOSAppId;
@synthesize appName;
@synthesize appDescription;
@synthesize appUrl;
@synthesize appIconUrl;

-(NSString *) getAppDescription
{
    if(self.description == nil)return @"";
    else return self.description;
}

-(void) setIOSAppId:(NSString *)aID
{
    NSLog(@"Setting is app id : %@", aID);
    
    self->iOSAppId = aID;
    
    //Grab the photo url as well.
    NSURL *appInfoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=%@", self.iOSAppId]];
    NSURLRequest *appInfoRequest = [NSURLRequest requestWithURL:appInfoURL];
    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:appInfoRequest returningResponse:&resp error:&err];
    NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 
    
    NSDictionary *appInfo = [theString objectFromJSONString];
    NSDictionary *appInfoResults = [[appInfo objectForKey:@"results"] objectAtIndex:0];
    
    self.appIconUrl = [appInfoResults objectForKey:@"artworkUrl512"];    
}

-(NSString *) getAppIconUrl
{
    if(self.appIconUrl != nil)return self.appIconUrl;   
    else return @"";
}

@end