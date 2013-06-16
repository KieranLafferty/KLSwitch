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
@property(nonatomic, strong) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *tintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) changeHandler didChangeHandler;

@property(nonatomic, getter=isOn) BOOL on;
@property(nonatomic, strong) UIColor* onColor;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame
   didChangeHandler:(changeHandler) didChangeHandler;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
@end

@interface KLSwitchKnob : UIView
-(id) initWithParentSwitch:(KLSwitch*) parentSwitch;
-(CGRect) trackingFrameForSwitch:(KLSwitch*) parentSwitch;
-(CGRect) frameForCurrentStateForSwitch:(KLSwitch*) parentSwitch;
-(void) setIsTracking:(BOOL)isTracking
             animated:(BOOL) animated;
@property (nonatomic, weak) KLSwitch* parentSwitch;
@property (nonatomic, assign) BOOL isTracking;

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
-(void) setOn:(BOOL) on animated:(BOOL) animated;
@end

