//
//  KLSwitch.m
//  KLSwitch
//
//  Created by Kieran Lafferty on 2013-06-15.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//

#import "KLSwitch.h"

#define kConstrainsFrameToProportions YES
#define kHeightWidthRatio 1.6451612903  //Magic number as a result of dividing the height by the width on the default UISwitch size (51/31)
//NSCoding Keys
#define kCodingOnKey @"on"
#define kCodingOnTintColorKey @"onColor"
#define kCodingOnColorKey @"onTintColor"    //Not implemented
#define kCodingTintColorKey @"tintColor"
#define kCodingThumbTintColorKey @"thumbTintColor"
#define kCodingOnImageKey @"onImage"
#define kCodingOffImageKey @"offImage"
#define kCodingConstrainFrameKey @"constrainFrame"

//Appearance Defaults - Colors
//Track Colors
#define kDefaultTrackOnColor     [UIColor colorWithRed:83/255.0 green: 214/255.0 blue: 105/255.0 alpha: 1]
#define kDefaultTrackOffColor    [UIColor colorWithWhite: 0.9f alpha:1.0f]
#define kDefaultTrackContrastColor [UIColor whiteColor]

//Thumb Colors
#define kDefaultThumbTintColor [UIColor whiteColor]
#define kDefaultThumbBorderColor [UIColor colorWithWhite: 0.9f alpha:1.0f]

//Appearance - Layout

//Size of knob with respect to the control - Must be a multiple of 2
#define kKnobOffset 2.0
#define kKnobTrackingGrowthRatio 1.2f                //Amount to grow the thumb on press down

#define kDefaultPanActivationThreshold 0.7                    //Number between 0.0 - 1.0 describing how far user must drag before initiating the switch

//Appearance - Animations
#define kDefaultAnimationSlideLength 0.25           //Length of time to slide the thumb from left/right to right/left
#define kDefaultAnimationScaleLength 0.25           //Length of time for the thumb to grow on press down

#define kSwitchTrackContrastViewShrinkFactor 0.0001f     //Must be very low btu not 0 or else causes iOS 5 issuess


@interface KLSwitchKnob : UIView
-(id) initWithParentSwitch:(KLSwitch*) parentSwitch;
-(void) setIsTracking:(BOOL) isTracking
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


@interface KLSwitch () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) KLSwitchTrack* track;
@property (nonatomic, strong) KLSwitchKnob* thumb;

//Gesture Recognizers
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
-(void) configureSwitch;
-(void) initializeDefaults;
-(void) toggleState;
@end

@implementation KLSwitch

#pragma mark - Initializers

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeBool: _on
                forKey: kCodingOnKey];
    
    [aCoder encodeObject: _onTintColor
                  forKey: kCodingOnTintColorKey];
    
    [aCoder encodeObject: _tintColor
                  forKey: kCodingTintColorKey];
    
    [aCoder encodeObject: _thumbTintColor
                  forKey: kCodingThumbTintColorKey];
    
    [aCoder encodeObject: _onImage
                  forKey: kCodingOnImageKey];
    
    [aCoder encodeObject: _offImage
                  forKey: kCodingOffImageKey];
    
    [aCoder encodeBool: _shouldConstrainFrame
                forKey: kCodingConstrainFrameKey];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [self initializeDefaults];
    if (self = [super initWithCoder: aDecoder]) {
        
        _on = [aDecoder decodeBoolForKey:kCodingOnKey];
        _onTintColor = [aDecoder decodeObjectForKey: kCodingOnTintColorKey];
        _tintColor = [aDecoder decodeObjectForKey: kCodingTintColorKey];
        _thumbTintColor = [aDecoder decodeObjectForKey: kCodingThumbTintColorKey];
        _onImage = [aDecoder decodeObjectForKey: kCodingOnImageKey];
        _offImage = [aDecoder decodeObjectForKey: kCodingOffImageKey];
        _onTintColor = [aDecoder decodeObjectForKey: kCodingOnTintColorKey];
        _shouldConstrainFrame = [aDecoder decodeBoolForKey: kCodingConstrainFrameKey];
        
        [self configureSwitch];

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSwitch];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
   didChangeHandler:(changeHandler) didChangeHandler {
    if (self = [self initWithFrame: frame]) {
        _didChangeHandler = didChangeHandler;
    }
    return self;
}
-(void) setFrame:(CGRect)frame {
    if (self.shouldConstrainFrame) {
        [super setFrame: CGRectMake(frame.origin.x, frame.origin.y, frame.size.height*kHeightWidthRatio, frame.size.height)];
    }
    else [super setFrame: frame];
}

#pragma mark - Defaults and layout/appearance

-(void) initializeDefaults {
    _onTintColor = kDefaultTrackOnColor;
    _tintColor = kDefaultTrackOffColor;
    _thumbTintColor = kDefaultThumbTintColor;
    _thumbBorderColor = kDefaultThumbBorderColor;
    _contrastColor = kDefaultThumbTintColor;
    _panActivationThreshold = kDefaultPanActivationThreshold;
    _shouldConstrainFrame = kConstrainsFrameToProportions;
}
-(void) configureSwitch {
    [self initializeDefaults];
 
    //Configure visual properties of self
    [self setBackgroundColor: [UIColor clearColor]];
    
    
    // tap gesture for toggling the switch
	self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didTap:)];
	[self.tapGesture setDelegate:self];
	[self addGestureRecognizer:self.tapGesture];
    
    
	// pan gesture for moving the switch knob manually
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didDrag:)];
	[self.panGesture setDelegate:self];
	[self addGestureRecognizer:self.panGesture];
    
    //Initialize the switch
    [self setOn: _on
       animated: NO];
}
-(void) layoutSubviews {
    [super layoutSubviews];
    /*
        View should be layered as follows : 
     
        TOP 
            thumb
            track
        BOTTOM
     */
    // Initialization code
    if (!_track) {
        _track = [[KLSwitchTrack alloc] initWithFrame: self.bounds
                                              onColor: self.onTintColor
                                             offColor: self.tintColor
                                        contrastColor: self.contrastColor];
        [_track setOn: self.isOn
             animated: NO];
        [self addSubview: self.track];
    }
    if (!_thumb) {
        _thumb = [[KLSwitchKnob alloc] initWithParentSwitch: self];
        [_thumb setParentSwitch: self];
        [_thumb setBackgroundColor: self.thumbTintColor];
        [self addSubview: _thumb];
    }
}
-(void) setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self.track setOnTintColor: _onTintColor];
}
-(void) setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self.track setTintColor: _tintColor];
}
-(void) setContrastColor:(UIColor *)contrastColor {
    _contrastColor = contrastColor;
    [self.track setContrastColor: _contrastColor];
}
-(void) setThumbBorderColor:(UIColor *)thumbBorderColor {
    _thumbBorderColor = thumbBorderColor;
    [self.thumb.layer setBorderColor: [_thumbBorderColor CGColor]];
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    //[self.trackingKnob setTintColor: self.thumbTintColor];
    [_thumb setBackgroundColor: [UIColor whiteColor]];
    
    //Make the knob a circle and add a shadow
    CGFloat roundedCornerRadius = self.thumb.frame.size.height/2.0f;
    [_thumb.layer setBorderWidth: 0.5];
    [_thumb.layer setBorderColor: [self.thumbBorderColor CGColor]];
    [_thumb.layer setCornerRadius: roundedCornerRadius];
    [_thumb.layer setShadowColor: [[UIColor grayColor] CGColor]];
    [_thumb.layer setShadowOffset: CGSizeMake(0, 4)];
    [_thumb.layer setShadowOpacity: 0.60f];
    [_thumb.layer setShadowRadius: 1.0];
}

#pragma mark - UIGestureRecognizer implementations
-(void) didTap:(UITapGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self toggleState];
    }
}
-(void) didDrag:(UIPanGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Grow the thumb horizontally towards center by defined ratio
        [self.thumb setIsTracking: YES
                         animated: YES];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        //If touch crosses the threshold then toggle the state
        CGPoint currentTouchLocation = [gesture locationInView: self];
        
        //Once location gets less than 0 or greater than width then toggle and cancel gesture
        CGFloat switchWidth = self.frame.size.width;
        if ((self.isOn && currentTouchLocation.x <= switchWidth - switchWidth*self.panActivationThreshold)
            || (!self.isOn && currentTouchLocation.x >= switchWidth*self.panActivationThreshold)) {
            [self toggleState];
        }
        
        CGPoint locationOfTouch = [gesture locationInView:self];
        if (CGRectContainsPoint(self.bounds, locationOfTouch))
            [self sendActionsForControlEvents:UIControlEventTouchDragInside];
        else
            [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
    else  if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.thumb setIsTracking: NO
                         animated: YES];
    }
}

#pragma mark - Event Handlers

-(void) toggleState {
    [self setOn: self.isOn ? NO : YES
       animated: YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self setOn: on];
    [self.thumb setIsTracking: NO
                     animated: animated];
    [self.track setOn: on
             animated: animated];
}
- (void) setOn:(BOOL)on {
    _on = on;
    //Trigger the completion block if exists
    if (self.didChangeHandler) {
        self.didChangeHandler(_on);
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    //Grow the thumb
    [self.thumb setIsTracking: YES
                     animated: YES];
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

@end


@implementation KLSwitchKnob
-(id) initWithParentSwitch:(KLSwitch*) parentSwitch {
    if (self = [super initWithFrame: [self frameForCurrentStateForSwitch: parentSwitch]]) {
        _parentSwitch = parentSwitch;
    }
    return self;
}
-(void) setIsTracking:(BOOL)isTracking {
    if (isTracking) {
        //Grow
        [self setFrame: [self trackingFrameForSwitch: self.parentSwitch]];
    }
    else {
        //Shrink
        [self setFrame: [self frameForCurrentStateForSwitch: self.parentSwitch]];
    }
    _isTracking = isTracking;
}
-(void) setIsTracking:(BOOL)isTracking
             animated:(BOOL) animated {
    [UIView animateWithDuration: kDefaultAnimationScaleLength
                          delay: fabs(kDefaultAnimationSlideLength - kDefaultAnimationScaleLength)
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         [self setIsTracking: isTracking];
                     }
                     completion:^(BOOL finished) {
         
                     }];

}
-(CGRect) trackingFrameForSwitch:(KLSwitch*) parentSwitch {
    //Round the scaled knob height to a multiple of 2
    CGFloat knobRadius = parentSwitch.bounds.size.height - roundf(kKnobOffset/2.0f) * 2.0f;
    CGFloat knobOffset = (parentSwitch.bounds.size.height - knobRadius)/2.0f;
    
    CGFloat knobWidth = knobRadius * kKnobTrackingGrowthRatio;
    CGFloat knobHeight = knobRadius;
    
    if (parentSwitch.isOn) {
        return CGRectMake(parentSwitch.frame.size.width - (knobWidth + knobOffset), knobOffset, knobWidth, knobHeight);
    }
    else {
        return CGRectMake(knobOffset, knobOffset, knobWidth, knobHeight);
    }
}
-(CGRect) frameForCurrentStateForSwitch:(KLSwitch*) parentSwitch {
    //Round the scaled knob height to a multiple of 2
    CGFloat knobRadius = parentSwitch.bounds.size.height - roundf(kKnobOffset/2.0f) * 2.0f;
    CGFloat knobOffset = (parentSwitch.bounds.size.height - knobRadius)/2.0f;
    
    if (parentSwitch.isOn) {
        return CGRectMake(parentSwitch.frame.size.width - knobRadius - knobOffset, knobOffset, knobRadius, knobRadius);
    }
    else {
        return CGRectMake(knobOffset, knobOffset, knobRadius, knobRadius);
    }
}
@end

@interface KLSwitchTrack ()
@property (nonatomic, strong) UIView* contrastView;
@property (nonatomic, strong) UIView* onView;
@end
@implementation KLSwitchTrack

-(id) initWithFrame:(CGRect)frame
            onColor:(UIColor*) onColor
           offColor:(UIColor*) offColor
      contrastColor:(UIColor*) contrastColor {
    if (self = [super initWithFrame: frame]) {
        _onTintColor = onColor;
        _tintColor = offColor;
        
        
        CGFloat cornerRadius = frame.size.height/2.0f;
        [self.layer setCornerRadius: cornerRadius];
        [self setBackgroundColor: _tintColor];
        
        CGRect contrastRect = frame;
        contrastRect.size.width = frame.size.width - 2*kKnobOffset;
        contrastRect.size.height = frame.size.height - 2*kKnobOffset;
        CGFloat contrastRadius = contrastRect.size.height/2.0f;

        _contrastView = [[UIView alloc] initWithFrame:contrastRect];
        [_contrastView setBackgroundColor: contrastColor];
        [_contrastView setCenter: self.center];
        [_contrastView.layer setCornerRadius: contrastRadius];
        [self addSubview: _contrastView];

         
        _onView = [[UIView alloc] initWithFrame:frame];
        [_onView setBackgroundColor: _onTintColor];
        [_onView setCenter: self.center];
        [_onView.layer setCornerRadius: cornerRadius];
        [self addSubview: _onView];

    }
    return self;
}
-(void) setOn:(BOOL)on {
    if (on) {
        [self.onView setAlpha: 1.0];
        [self shrinkContrastView];
    }
    else {
        [self.onView setAlpha: 0.0];
        [self growContrastView];
    }
}
-(void) setOn:(BOOL)on animated:(BOOL)animated {
    if (animated) {
        //First animate the color switch
        [UIView animateWithDuration: kDefaultAnimationSlideLength
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self setOn: on
                                animated: NO];
                         }
                         completion:nil];
    }
    else {
        [self setOn: on];
    }
}

-(void) growContrastView {
    //Start out with contrast view small and centered
    [self.contrastView setTransform: CGAffineTransformMakeScale(kSwitchTrackContrastViewShrinkFactor, kSwitchTrackContrastViewShrinkFactor)];
    [self.contrastView setTransform: CGAffineTransformMakeScale(1, 1)];
}
-(void) shrinkContrastView {
    //Start out with contrast view the size of the track
    [self.contrastView setTransform: CGAffineTransformMakeScale(1, 1)];
    [self.contrastView setTransform: CGAffineTransformMakeScale(kSwitchTrackContrastViewShrinkFactor, kSwitchTrackContrastViewShrinkFactor)];
}

@end
