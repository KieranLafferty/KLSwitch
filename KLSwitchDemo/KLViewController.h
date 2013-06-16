//
//  KLViewController.h
//  KLSwitchDemo
//
//  Created by Kieran Lafferty on 2013-06-16.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KLSwitch/KLSwitch.h>
@interface KLViewController : UIViewController
@property (weak, nonatomic) IBOutlet KLSwitch *smallestSwitch;
@property (weak, nonatomic) IBOutlet KLSwitch *smallSwitch;
@property (weak, nonatomic) IBOutlet KLSwitch *mediumSwitch;
@property (weak, nonatomic) IBOutlet KLSwitch *bigSwitch;
@property (weak, nonatomic) IBOutlet KLSwitch *biggestSwitch;
@end
