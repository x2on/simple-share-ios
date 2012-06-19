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

//604800 seconds is one week.
#define kFBConfigIconURLCacheTime 604800

@interface SimpleFacebookConfiguration (PrivateMethods)
-(BOOL) appIconIsCached;
-(void) fetchIcon;
@end


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
    if(![self appIconIsCached])[self fetchIcon];
}

-(NSString *) getAppIconUrl
{
    if(self.appIconUrl != nil)return self.appIconUrl;   
    else return @"";
}

-(BOOL) appIconIsCached
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:@"kFBConfigAppIconURL"] != nil)
    {
        //The app icon url exists. Lets check the expiry time.
        NSDate *fetchedDate = (NSDate *)[defaults objectForKey:@"kFBConfigAppIconURLFetched"];
        if(fabsf([fetchedDate timeIntervalSinceNow]) > kFBConfigIconURLCacheTime) return NO;
        else
        {
            self.appIconUrl = [defaults stringForKey:@"kFBConfigAppIconURL"];
            return YES;   
        }
    }
    
    return NO;
}

-(void) fetchIcon
{
    NSURL *appInfoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=%@", self.iOSAppId]];

    //AsynchronousRequest to grab the data
    NSURLRequest *request = [NSURLRequest requestWithURL:appInfoURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if(data)
        {
            NSString* returnedDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *appInfo = [returnedDataString objectFromJSONString];
            NSDictionary *appInfoResults = [[appInfo objectForKey:@"results"] objectAtIndex:0];
            
            self.appIconUrl = [appInfoResults objectForKey:@"artworkUrl512"];
            
            //Set the defaults
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:self.appIconUrl forKey:@"kFBConfigAppIconURL"];
            [defaults setObject:[NSDate date] forKey:@"kFBConfigAppIconURLFetched"];
            [defaults synchronize];                          
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];    
}

@end