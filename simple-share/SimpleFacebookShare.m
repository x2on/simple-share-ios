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
    [FBSession.activeSession closeAndClearTokenInformation];
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
        [self _shareAndOpenSession:params];
    }
}

- (void)_shareAndReauthorize:(NSDictionary *)params {
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_stream"]
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
}


- (void)close {
    [FBSession.activeSession close];
}

- (void)handleDidBecomeActive {
    [FBSession.activeSession handleDidBecomeActive];
}

@end
