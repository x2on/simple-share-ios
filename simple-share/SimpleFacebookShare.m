//
//  SimpleFacebookShare.m
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

#import "SimpleFacebookShare.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"
#import "SSKeychain.h"
#import "SimpleFacebookConfiguration.h"

#define FACEBOOK_ACCESS_TOKEN_KEY @"kSHKFacebookAccessToken"
#define FACEBOOK_EXPIRY_DATE_KEY @"kSHKFacebookExpiryDate"
#define FACEBOOK_SERVICE @"SFFacebookShare"

@implementation SimpleFacebookShare {
    NSString *appId;
    NSString *appActionLink;
    Facebook *facebook;
}

- (id) initWithSimpleFacebookConfiguration:(SimpleFacebookConfiguration *)theSimpleFacebookConfiguration {
    self = [super init];
    if (self) {
        config = theSimpleFacebookConfiguration;
        appId = config.appId;
        NSAssert(appId, @"AppId must be defined");
        facebook = [[Facebook alloc] initWithAppId:appId andDelegate:self];
        [self loadCredentials];
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:config.appName, @"name", config.appUrl, @"link", nil], nil];
        appActionLink = [actionLinks JSONString];
        [facebook extendAccessTokenIfNeeded];

    }
    return self;
}

- (BOOL) handleOpenURL:(NSURL *)theUrl {
    return [facebook handleOpenURL:theUrl];
}

- (void) authorizesIfNeeded {
    if (![facebook isSessionValid]) {
        NSLog(@"Login");
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", nil];
        [facebook authorize:permissions];
    }
}

- (bool) isAuthorized
{
    return [facebook isSessionValid];
}

- (void) logOut {
    [facebook logout];
}

- (void) shareParams:(NSMutableDictionary *)theParams {
    if ([facebook isSessionValid]) {
        [facebook dialog:@"feed" andParams:theParams andDelegate:self];
    }
    else {
        [self authorizesIfNeeded];
    }
}

- (void) shareUrl:(NSURL *)theUrl {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[theUrl absoluteString], @"link", appActionLink, @"actions", nil];
    [self shareParams:params];
}

- (void) shareText:(NSString *)theText {

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   //appActionLink, @"link",
                                   theText, @"description",
                                   config.appDescription, @"caption",
                                   config.appName, @"name",
                                   config.appIconUrl, @"picture",
                                   nil];
    [self shareParams:params];
}

#pragma mark - FBDialogDelegate

- (void) dialogDidComplete:(FBDialog *)dialog {
    //Do nothing
}

- (void) dialogCompleteWithUrl:(NSURL *)url {
    if (![url query]) {
        NSLog(@"User canceled dialog or there was an error");
        return;
    }

    NSDictionary *params = [self parseURLParams:[url query]];

    // Successful posts return a post_id
    if ([params valueForKey:@"post_id"]) {
        [SVProgressHUD showSuccessWithStatus:@"Gespeichert"];
    }
}

- (NSDictionary *) parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (void) dialogDidNotCompleteWithUrl:(NSURL *)url {
    //Do nothing
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
    //Do nothing
}

- (void) dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (BOOL) dialog:(FBDialog *)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
    return NO;
}

#pragma mark - FBSessionDelegate

- (void) fbSessionInvalidated {
    [self removeFacebookCredentials];
}

- (void) fbDidLogin {
    [self saveCredentials:facebook.accessToken expiresAt:facebook.expirationDate];

}

- (void) fbDidNotLogin:(BOOL)cancelled {

}

- (void) fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [self saveCredentials:accessToken expiresAt:expiresAt];
}

- (void) fbDidLogout {
    [self removeFacebookCredentials];
}

#pragma mark - Helper

- (void) saveCredentials:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [SSKeychain setPassword:accessToken forService:FACEBOOK_SERVICE account:FACEBOOK_ACCESS_TOKEN_KEY];
    [SSKeychain setPassword:[self dateToString:expiresAt] forService:FACEBOOK_SERVICE account:FACEBOOK_EXPIRY_DATE_KEY];
}

- (void) removeFacebookCredentials {
    [SSKeychain deletePasswordForService:FACEBOOK_SERVICE account:FACEBOOK_ACCESS_TOKEN_KEY];
    [SSKeychain deletePasswordForService:FACEBOOK_SERVICE account:FACEBOOK_EXPIRY_DATE_KEY];
}

- (void) loadCredentials {
    NSString *accessToken = [SSKeychain passwordForService:FACEBOOK_SERVICE account:FACEBOOK_ACCESS_TOKEN_KEY];
    NSString *expirationDate = [SSKeychain passwordForService:FACEBOOK_SERVICE account:FACEBOOK_EXPIRY_DATE_KEY];

    if (accessToken && expirationDate) {
        facebook.accessToken = accessToken;
        facebook.expirationDate = [self stringToDate:expirationDate];
    }
}

- (NSString *) dateToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

- (NSDate *) stringToDate:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter dateFromString:string];
}

@end
