//
//  KLSwitch.h
//  KLSwitch
//
//  Created by Kieran Lafferty on 2013-06-15.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef void(^changeHandler)(BOOL isOn);

@interface KLSwitch : UIControl <NSCoding>
//UISwitch interface
@property(nonatomic, strong) UIImage *onImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;         //Currently this does nothing
@property(nonatomic, strong) UIImage *offImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;        //Currently this does nothing

@property(nonatomic, strong) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *tintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;


///Additional color options provided by KLSwitch only
@property(nonatomic, strong) UIColor *contrastColor;
@property(nonatomic, strong) UIColor *thumbBorderColor;


@property(nonatomic, getter=isOn) BOOL on;

//Custom completion block initiated by value change (on/off)
@property(nonatomic, copy) changeHandler didChangeHandler;

//Percent (0.0 - 1.0) of the control to travel while panning before a switch toggle is activated
@property(nonatomic, assign) CGFloat panActivationThreshold;

//Set to true if you want to maintain 51x31 proportions, false if you want to set the frame to anything
@property(nonatomic, assign) BOOL shouldConstrainFrame;

//Initializers
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame
   didChangeHandler:(changeHandler) didChangeHandler;

//Events
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

