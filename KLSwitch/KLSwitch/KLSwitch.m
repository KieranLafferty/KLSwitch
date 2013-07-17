//
//  KLSwitch.m
//  KLSwitch
//
//  Created by Kieran Lafferty on 2013-06-15.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//
// https://github.com/KieranLafferty/KLSwitch

#import "KLSwitch.h"

#define kConstrainsFrameToProportions YES
#define kHeightWidthRatio 1.6451612903  //Magic number as a result of dividing the height by the width on the default UISwitch size (51/31)

//NSCoding Keys
#define kCodingOnKey @"on"
#define kCodingLockedKey @"off"
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
#define kThumbOffset 1
#define kThumbTrackingGrowthRatio 1.2f                //Amount to grow the thumb on press down

#define kDefaultPanActivationThreshold 0.7                    //Number between 0.0 - 1.0 describing how far user must drag before initiating the switch

//Appearance - Animations
#define kDefaultAnimationSlideLength 0.25f           //Length of time to slide the thumb from left/right to right/left
#define kDefaultAnimationScaleLength 0.15f           //Length of time for the thumb to grow on press down
#define kDefaultAnimationContrastResizeLength 0.25f           //Length of time for the thumb to grow on press down

#define kSwitchTrackContrastViewShrinkFactor 0.0001f     //Must be very low but not 0 or else causes iOS 5 issues

typedef enum {
    KLSwitchThumbJustifyLeft,
    KLSwitchThumbJustifyRight
} KLSwitchThumbJustify;

@interface KLSwitchThumb : UIView
@property (nonatomic, assign) BOOL isTracking;
-(void) growThumbWithJustification:(KLSwitchThumbJustify) justification;
-(void) shrinkThumbWithJustification:(KLSwitchThumbJustify) justification;
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
@property (nonatomic, strong) KLSwitchThumb* thumb;

//Gesture Recognizers
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
-(void) configureSwitch;
-(void) initializeDefaults;
-(void) toggleState;
-(void) setThumbOn:(BOOL) on
          animated:(BOOL) animated;

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
        _locked = [aDecoder decodeBoolForKey:kCodingLockedKey];
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
    
    /*
     Subview layering as follows :
     
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
        _thumb = [[KLSwitchThumb alloc] initWithFrame:CGRectMake(kThumbOffset, kThumbOffset, self.bounds.size.height - 2 * kThumbOffset, self.bounds.size.height - 2 * kThumbOffset)];
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
    CGFloat roundedCornerRadius = _thumb.frame.size.height/2.0f;
    [_thumb.layer setBorderWidth: 0.5];
    [_thumb.layer setBorderColor: [self.thumbBorderColor CGColor]];
    [_thumb.layer setCornerRadius: roundedCornerRadius];
    [_thumb.layer setShadowColor: [[UIColor grayColor] CGColor]];
    [_thumb.layer setShadowOffset: CGSizeMake(0, 3)];
    [_thumb.layer setShadowOpacity: 0.40f];
    [_thumb.layer setShadowRadius: 0.8];
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
        [self setThumbIsTracking: YES
                   animated: YES];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        //If touch crosses the threshold then toggle the state
        CGPoint locationInThumb = [gesture locationInView: self.thumb];
        
        //Toggle the switch if the user pans left or right past the switch thumb bounds
        if ((self.isOn && locationInThumb.x <= 0)
            || (!self.isOn && locationInThumb.x >= self.thumb.bounds.size.width)) {
            [self toggleState];
        }
        
        CGPoint locationOfTouch = [gesture locationInView:self];
        if (CGRectContainsPoint(self.bounds, locationOfTouch))
            [self sendActionsForControlEvents:UIControlEventTouchDragInside];
        else
            [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
    else  if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setThumbIsTracking: NO
                   animated: YES];
    }
}

#pragma mark - Event Handlers

-(void) toggleState {
    //Alternate between on/off
    [self setOn: self.isOn ? NO : YES
       animated: YES];
}

- (void)setOn:(BOOL)on
     animated:(BOOL)animated {
    //Cancel notification to parent if attempting to set to current state
    if (_on == on) {
        return;
    }
    
    //Move the thumb to the new position
    [self setThumbOn: on
            animated: animated];
    
    //Animate the contrast view of the track
    [self.track setOn: on
             animated: animated];
    
    _on = on;
    
    //Trigger the completion block if exists
    if (self.didChangeHandler) {
        self.didChangeHandler(_on);
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) setOn:(BOOL)on {
    [self setOn: on animated: NO];
}

- (void) setLocked:(BOOL)locked {
    //Cancel notification to parent if attempting to set to current state
    if (_locked == locked) {
        return;
    }
    _locked = locked;

    UIImageView *lockImageView = (UIImageView *)[_track viewWithTag:LOCK_IMAGE_SUBVIEW];
    
    if (!locked && (lockImageView != nil)) {
        
        [lockImageView removeFromSuperview];
        lockImageView = nil;
        
    } else if (locked && (lockImageView == nil)) {
        
        UIImage *lockImage = [UIImage imageNamed:@"lock-icon.png"];
        
        lockImageView = [[UIImageView alloc] initWithImage:lockImage];
        
        lockImageView.frame = CGRectMake(7, 8, lockImage.size.width, lockImage.size.height);
        lockImageView.tag = LOCK_IMAGE_SUBVIEW;
        
        [_track addSubview:lockImageView];
        [_track bringSubviewToFront:lockImageView];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
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

-(void) setThumbIsTracking:(BOOL)isTracking {
    if (isTracking) {
        //Grow
        [self.thumb growThumbWithJustification: self.isOn ? KLSwitchThumbJustifyRight : KLSwitchThumbJustifyLeft];
    }
    else {
        //Shrink
        [self.thumb shrinkThumbWithJustification: self.isOn ? KLSwitchThumbJustifyRight : KLSwitchThumbJustifyLeft];
    }
    [self.thumb setIsTracking: isTracking];
}
-(void) setThumbIsTracking:(BOOL)isTracking
             animated:(BOOL) animated {
    __weak id weakSelf = self;
    [UIView animateWithDuration: kDefaultAnimationScaleLength
                          delay: fabs(kDefaultAnimationSlideLength - kDefaultAnimationScaleLength)
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         [weakSelf setThumbIsTracking: isTracking];
                     }
                     completion:nil];
}
-(void) setThumbOn:(BOOL) on
          animated:(BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setThumbOn:on animated:NO];
        }];
    }
    CGRect thumbFrame = self.thumb.frame;
    if (on) {
        thumbFrame.origin.x = self.bounds.size.width - (thumbFrame.size.width + kThumbOffset);
    }
    else {
        thumbFrame.origin.x = kThumbOffset;
    }
    [self.thumb setFrame: thumbFrame];
}
@end


@implementation KLSwitchThumb

-(void) growThumbWithJustification:(KLSwitchThumbJustify) justification {
    if (self.isTracking) 
        return;

    CGRect thumbFrame = self.frame;
    
    CGFloat deltaWidth = self.frame.size.width * (kThumbTrackingGrowthRatio - 1);
    thumbFrame.size.width += deltaWidth;
    if (justification == KLSwitchThumbJustifyRight) {
        thumbFrame.origin.x -= deltaWidth;
    }
    [self setFrame: thumbFrame];
}
-(void) shrinkThumbWithJustification:(KLSwitchThumbJustify) justification {
    if (!self.isTracking) 
        return;

    CGRect thumbFrame = self.frame;
    
    CGFloat deltaWidth = self.frame.size.width * (1 - 1 / (kThumbTrackingGrowthRatio));
    thumbFrame.size.width -= deltaWidth;
    if (justification == KLSwitchThumbJustifyRight) {
        thumbFrame.origin.x += deltaWidth;
    }
    [self setFrame: thumbFrame];

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
        contrastRect.size.width = frame.size.width - 2*kThumbOffset;
        contrastRect.size.height = frame.size.height - 2*kThumbOffset;
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

-(void) setOn:(BOOL)on
     animated:(BOOL)animated {
    if (animated) {
        __weak id weakSelf = self;
            //First animate the color switch
        [UIView animateWithDuration: kDefaultAnimationContrastResizeLength
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [weakSelf setOn: on
                                animated: NO];
                         }
                         completion:nil];
    }
    else {
        [self setOn: on];
    }
}

-(void) setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self.onView setBackgroundColor: _onTintColor];
}

-(void) setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self setBackgroundColor: _tintColor];
}

-(void) setContrastColor:(UIColor *)contrastColor {
    _contrastColor = contrastColor;
    [self.contrastView setBackgroundColor: _contrastColor];
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
