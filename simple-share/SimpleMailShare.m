//
//  SimpleMailShare.h
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

#import "SimpleMailShare.h"
#import "ViewControllerHelper.h"

@implementation SimpleMailShare {
    MFMailComposeViewController *mailComposeViewController;
}

- (void) dealloc {
    mailComposeViewController.mailComposeDelegate = nil;
}

- (BOOL) canSendMail {
    return [MFMailComposeViewController canSendMail];
}

- (void) shareText:(NSString *)text subject:(NSString *)subject isHTML:(BOOL)isHTML {
    if ([self canSendMail]) {
        mailComposeViewController.mailComposeDelegate = nil;
        mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:subject];
        [mailComposeViewController setMessageBody:text isHTML:isHTML];

        UIViewController *viewController = [ViewControllerHelper getCurrentRootViewController];
        [viewController presentModalViewController:mailComposeViewController animated:YES];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [mailComposeViewController dismissModalViewControllerAnimated:YES];
}

@end