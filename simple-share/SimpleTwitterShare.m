//
//  SimpleTwitterShare.m
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

#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "SimpleTwitterShare.h"
#import "ViewControllerHelper.h"
#import "SVProgressHUD.h"


@implementation SimpleTwitterShare {

}

- (BOOL) canSendTweet {
    Class socialClass = NSClassFromString(@"SLComposeViewController");
    if (socialClass != nil) {
        return YES;
    }
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    if (tweeterClass == nil) {
        return NO;
    }
    if ([TWTweetComposeViewController canSendTweet]) {
        return YES;
    }
    return NO;
}

- (void) shareText:(NSString *)theText {
    if ([self canSendTweet]) {

        UIViewController *viewController = [ViewControllerHelper getCurrentRootViewController];

        Class socialClass = NSClassFromString(@"SLComposeViewController");
        if (socialClass != nil) {
            SLComposeViewController *twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            twitterController.completionHandler = ^(SLComposeViewControllerResult result) {
                [twitterController dismissViewControllerAnimated:YES completion:nil];
                if (result == SLComposeViewControllerResultDone) {
                    [SVProgressHUD showSuccessWithStatus:@"Gespeichert"];
                }

            };
            [twitterController setInitialText:theText];
            [viewController presentViewController:twitterController animated:YES completion:nil];

        } else {


            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            [tweetViewController setInitialText:theText];

            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                if (result == TWTweetComposeViewControllerResultDone) {
                } else if (result == TWTweetComposeViewControllerResultCancelled) {
                }
                [viewController dismissViewControllerAnimated:YES completion:nil];
            };

            [viewController presentViewController:tweetViewController animated:YES completion:nil];
        }
    }
}

@end