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
@property(nonatomic, strong) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *tintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
///Additional color options provided by KLSwitch only
@property(nonatomic, strong) UIColor *contrastColor;
@property(nonatomic, strong) UIColor *thumbBorderColor;


@property(nonatomic, getter=isOn) BOOL on;

//Custom completion block initiated by value change (on/off)
@property(nonatomic, copy) changeHandler didChangeHandler;

//Appearance attributes for switch

//Initializers
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame
   didChangeHandler:(changeHandler) didChangeHandler;

//Events
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

@interface KLSwitchKnob : UIView
-(id) initWithParentSwitch:(KLSwitch*) parentSwitch;
-(void) setIsTracking:(BOOL)isTracking
             animated:(BOOL) animated;
@property (nonatomic, weak) KLSwitch* parentSwitch;
@property (nonatomic, assign) BOOL isTracking;
-(CGRect) trackingFrameForSwitch:(KLSwitch*) parentSwitch;
-(CGRect) frameForCurrentStateForSwitch:(KLSwitch*) parentSwitch;
@end

@interface KLSwitchTrack : UIView
@property(nonatomic, getter=isOn) BOOL on;
@property (nonatomic, strong) UIColor* contrastColor;
@property (nonatomic, strong) UIColor* onTintColor;
@property (nonatomic, strong) UIColor* tintColor;
-(id) initWithFrame:(CGRect)frame
            onColor:(UIColor*) onColor
           offColor:(UIColor*) offColor
      contrastColor:(UIColor*) contrastColor;
-(void) growContrastView;
-(void) shrinkContrastView;
-(void) setOn:(BOOL) on
     animated:(BOOL) animated;
@end

