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

@implementation SimpleFacebookShare {
    NSString *appActionLink;
}

- (id)initWithAppName:(NSString *)theAppName appUrl:(NSString *)theAppUrl {
    self = [super init];
    if (self) {
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:theAppName, @"name", theAppUrl, @"link", nil], nil];
        NSError *error = nil;

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:actionLinks options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        appActionLink = jsonString;
    }
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)theUrl {
    return [FBSession.activeSession handleOpenURL:theUrl];
}


- (void)logOut {
    [_facebook logout];
    self.facebook = nil;
    [FBSession.activeSession closeAndClearTokenInformation];
    
    //Delete data from User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenInformationKey"];
    
    //Remove facebook Cookies:
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain isEqualToString:@".facebook.com"] || [cookie.domain isEqualToString:@"facebook.com"]) {
            [storage deleteCookie:cookie];
            NSLog(@"Delete facebook cookie: %@",cookie);
        }
    }
    [defaults synchronize];
}

- (void)shareUrl:(NSURL *)theUrl {
    [self _shareInitalParams:@{
            @"link" : [theUrl absoluteString],
            @"actions" : appActionLink
    }];
}


- (void)shareText:(NSString *)theText {
    [self _shareInitalParams:@{
            @"description" : theText,
            @"actions" : appActionLink
    }];
}

- (void)_shareInitalParams:(NSDictionary *)params {
    if (FBSession.activeSession.isOpen) {
        [self _shareAndReauthorize:params];
    }
    else {
        self.facebook = nil;
        [self _shareAndOpenSession:params];
    }
}

- (void)_shareAndReauthorize:(NSDictionary *)params {
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
        [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_stream"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         NSLog(@"Fehler bei der Authorizierung: %@", error);
                                                         [SVProgressHUD showErrorWithStatus:@"Fehler bei der Authorizierung."];
                                                     }
                                                     else {
                                                         [self _shareParams:params];

                                                     }
                                                 }];
    }
    else {
        [self _shareParams:params];
    }
}

- (void)_shareAndOpenSession:(NSDictionary *)params {

    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self _shareAndReauthorize:params];
        }];
    }
    else {
        [FBSession openActiveSessionWithPermissions:[NSArray arrayWithObject:@"publish_stream"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                NSLog(@"Fehler bei der Authorizierung: %@", error);
                [SVProgressHUD showErrorWithStatus:@"Fehler bei der Authorizierung."];
            }
            else {
                [self _shareAndReauthorize:params];
            }
        }];
    }
}

- (void)_shareParams:(NSDictionary *)params {
    // Initiate a Facebook instance and properties
    if (_facebook == nil) {
        self.facebook = [[Facebook alloc] initWithAppId:FBSession.activeSession.appID andDelegate:nil];
        self.facebook.accessToken = FBSession.activeSession.accessToken;
        self.facebook.expirationDate = FBSession.activeSession.expirationDate;
    }

    [_facebook dialog:@"feed" andParams:[params mutableCopy] andDelegate:self];
/*
    // Post without Facebook Dialog GUI:
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  NSLog(@"Fehler beim Speichern: %@", error);
                                  [SVProgressHUD showErrorWithStatus:@"Fehler beim Speichern."];
                              }
                              else {
                                  [SVProgressHUD showSuccessWithStatus:@"Gespeichert"];
                              }
                          }];
 */
}

- (void) getUsernameWithCompletionHandler:(void (^)(NSString *username, NSError *error))completionHandler {
    if (completionHandler) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            __weak SimpleFacebookShare *selfForBlock = self;
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [selfForBlock _getUserNameWithCompletionHandlerOnActiveSession:completionHandler];

            }];
        }
        [self _getUserNameWithCompletionHandlerOnActiveSession:completionHandler];
    }
}

- (void) _getUserNameWithCompletionHandlerOnActiveSession:(void (^)(NSString *username, NSError *error))completionHandler {
    [FBRequestConnection startWithGraphPath:@"me"
                                 parameters:nil HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  completionHandler(nil, error);
                              }
                              else {
                                  NSString *username = [result objectForKey:@"name"];
                                  completionHandler(username, nil);
                              }
                          }];
}

- (BOOL) isLoggedIn {
    FBSessionState state = FBSession.activeSession.state;
    if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded || state == FBSessionStateOpenTokenExtended) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)close {
    [FBSession.activeSession close];
}

- (void)handleDidBecomeActive {
    [FBSession.activeSession handleDidBecomeActive];
}

#pragma mark - FBDialogDelegate

- (void)dialogCompleteWithUrl:(NSURL *)url {
    NSDictionary *params = [self _parseURLParams:[url query]];
    if ([params valueForKey:@"post_id"]) {
        [SVProgressHUD showSuccessWithStatus:@"Gespeichert"];
    }
    else if ([params valueForKey:@"error_code"]) {
        [SVProgressHUD showErrorWithStatus:@"Leider ist ein Fehler aufgetreten."];
        NSLog(@"Error: %@",[params valueForKey:@"error_msg"]);
    }
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    //Do nothing
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    //Do nothing
}

- (void)dialogDidComplete:(FBDialog *)dialog {
    //Do nothing
}

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    NSLog(@"Fehler beim Speichern: %@", error);
    [SVProgressHUD showErrorWithStatus:@"Fehler beim Speichern."];
}

- (NSDictionary *)_parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
                [[kv objectAtIndex:1]
                        stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}


@end
