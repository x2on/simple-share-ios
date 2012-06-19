//
//  ViewController.m
//  simple-share-demo
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

#import "ViewController.h"
#import "SimpleFacebookShare.h"
#import "SimpleTwitterShare.h"
#import "SimpleMailShare.h"

@interface ViewController ()

@end

@implementation ViewController {
    SimpleFacebookShare *facebookShare;
    SimpleMailShare *simpleMailShare;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil simpleFacebookShare:(SimpleFacebookShare *)theSimpleFacebookShare {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        facebookShare = theSimpleFacebookShare;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)facebookButtonPressed:(id)sender {
    [facebookShare shareUrl:[NSURL URLWithString:@"http://www.felixschulze.de"]];
}

- (IBAction)twitterButtonPressed:(id)sender {
    SimpleTwitterShare *simpleTwitterShare = [[SimpleTwitterShare alloc] init];
    if ([simpleTwitterShare canSendTweet]) {
        [simpleTwitterShare shareText:@"Some text to share"];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not supported" message:@"Twitter is not supported" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)mailButtonPressed:(id)sender {
    if(simpleMailShare == nil)
        simpleMailShare = [[SimpleMailShare alloc] init];    

    [simpleMailShare shareText:@"Some text to email." subject:@"The Subject" isHTML:NO];
}

@end
