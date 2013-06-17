//
//  KLViewController.m
//  KLSwitchDemo
//
//  Created by Kieran Lafferty on 2013-06-16.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//

#import "KLViewController.h"
#define kGreenColor [UIColor colorWithRed:144/255.0 green: 202/255.0 blue: 119/255.0 alpha: 1.0]
#define kBlueColor [UIColor colorWithRed:129/255.0 green: 198/255.0 blue: 221/255.0 alpha: 1.0]
#define kYellowColor [UIColor colorWithRed:233/255.0 green: 182/255.0 blue: 77/255.0 alpha: 1.0]
#define kOrangeColor [UIColor colorWithRed:288/255.0 green: 135/255.0 blue: 67/255.0 alpha: 1.0]
#define kRedColor [UIColor colorWithRed:158/255.0 green: 59/255.0 blue: 51/255.0 alpha: 1.0]
@interface KLViewController ()

@end

@implementation KLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [KLSwitch class]; //Required for the class to be linked properly when only linked through IB
    
    [self.smallestSwitch setOnTintColor: kGreenColor];
    [self.smallSwitch setOnTintColor: kBlueColor];
    [self.mediumSwitch setOnTintColor: kYellowColor];
    [self.bigSwitch setOnTintColor: kOrangeColor];
    [self.biggestSwitch setOnTintColor: kRedColor];
    
    [self.smallestSwitch setOn: YES
                      animated: YES];
    [self.smallestSwitch setDidChangeHandler:^(BOOL isOn) {
        NSLog(@"Smallest switch changed to %d", isOn);
    }];
    
    [self.smallSwitch setOn: YES
                   animated: YES];
    [self.smallSwitch setDidChangeHandler:^(BOOL isOn) {
        NSLog(@"Small switch changed to %d", isOn);
    }];
    
    [self.mediumSwitch setOn: YES
                    animated: YES];
    [self.mediumSwitch setDidChangeHandler:^(BOOL isOn) {
        NSLog(@"Medium switch changed to %d", isOn);
    }];
    
    [self.bigSwitch setOn: YES
                 animated: YES];
    [self.bigSwitch setDidChangeHandler:^(BOOL isOn) {
        NSLog(@"Big switch changed to %d", isOn);
    }];
    
    [self.biggestSwitch setOn: YES
                     animated: YES];
    [self.biggestSwitch setDidChangeHandler:^(BOOL isOn) {
        NSLog(@"Biggest switch changed to %d", isOn);
    }];
}

@end
