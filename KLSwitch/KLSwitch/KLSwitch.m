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
#define kKnobOffset 1.0
#define kKnobTrackingGrowthRatio 1.2f                //Amount to grow the thumb on press down

//Appearance - Animations
#define kDefaultAnimationLength 0.3           //Length of time to animate

#define kSwitchTrackContrastViewShrinkFactor 0.0001f     //Must be very low btu not 0 or else causes iOS 5 issuess


@interface KLSwitchKnob : UIView
@property (nonatomic, readonly, assign) BOOL isTracking;
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

//Animation blocks

//Switch

-(void) moveThumbToPositionOn:(BOOL) on;
-(void) moveThumbToPositionOn:(BOOL) on
                     animated:(BOOL) animated;
-(void) moveThumbToPositionOn:(BOOL) on
                     animated:(BOOL) animated
                   completion:(void (^)(BOOL finished))completion;

-(void) setTrackOn:(BOOL) on;
-(void) setTrackOn:(BOOL) on
          animated:(BOOL) animated;
-(void) setTrackOn:(BOOL) on
          animated:(BOOL) animated
        completion:(void (^)(BOOL finished))completion;


-(void) shrinkThumbAnimated:(BOOL) animated;
-(void) shrinkThumbAnimated:(BOOL) animated
                 completion:(void (^)(BOOL finished))completion;

-(void) growThumbAnimated:(BOOL) animated;
-(void) growThumbAnimated:(BOOL) animated
                 completion:(void (^)(BOOL finished))completion;

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
-(void) initializeDefaults {
    _onTintColor = kDefaultTrackOnColor;
    _tintColor = kDefaultTrackOffColor;
    _thumbTintColor = kDefaultThumbTintColor;
    _thumbBorderColor = kDefaultThumbBorderColor;
    _contrastColor = kDefaultThumbTintColor;
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
    CGFloat controlHeight = self.bounds.size.height;
    if (!_track) {
        _track = [[KLSwitchTrack alloc] initWithFrame: self.bounds
                                              onColor: self.onTintColor
                                             offColor: self.tintColor
                                        contrastColor: self.contrastColor];
        [_track setOn: _on];
        [self addSubview: self.track];
    }
    if (!_thumb) {
        CGFloat thumbRadius = controlHeight - 2*kKnobOffset;
        _thumb = [[KLSwitchKnob alloc] initWithFrame: CGRectMake(kKnobOffset, kKnobOffset, thumbRadius, thumbRadius)];
        [self addSubview: _thumb];
    }
    [self setOn: _on animated:NO];
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

#pragma mark - Animations

-(void) shrinkThumbAnimated:(BOOL) animated {
    [self shrinkThumbAnimated: animated
                   completion: nil];
}
-(void) shrinkThumbAnimated:(BOOL) animated
                 completion:(void (^)(BOOL finished))completion {
    if (animated) {
        __weak KLSwitch* weakSelf = self;
        [UIView animateWithDuration: kDefaultAnimationLength
                         animations: ^{
                             [weakSelf shrinkThumbAnimated:NO];
                         } completion:completion];
        return;
    }
    CGRect thumbFrame = self.thumb.frame;
    thumbFrame.size.width = self.bounds.size.height - 2 * kKnobOffset;
    [self.thumb setFrame: thumbFrame];
}

-(void) growThumbAnimated:(BOOL) animated {
    [self growThumbAnimated: animated
                 completion: nil];
}
-(void) growThumbAnimated:(BOOL) animated
               completion:(void (^)(BOOL finished))completion {
    if (animated) {
        __weak KLSwitch* weakSelf = self;
        [UIView animateWithDuration: kDefaultAnimationLength
                         animations: ^{
                             [weakSelf growThumbAnimated:NO];
                         }];
        return;
    }
    CGRect thumbFrame = self.thumb.frame;
    thumbFrame.size.width = thumbFrame.size.width * kKnobTrackingGrowthRatio;
    [self.thumb setFrame: thumbFrame];
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
        [self growThumbAnimated:YES];

    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint currentTouchLocation = [gesture locationInView: self.thumb];
    
        if ((self.isOn && currentTouchLocation.x <= 0)
            || (!self.isOn && currentTouchLocation.x >= self.thumb.bounds.size.width)) {
            [self toggleState];
        }        
        CGPoint locationOfTouch = [gesture locationInView:self];
        if (CGRectContainsPoint(self.bounds, locationOfTouch))
            [self sendActionsForControlEvents:UIControlEventTouchDragInside];
        else
            [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
    else  if (gesture.state == UIGestureRecognizerStateEnded) {
        [self shrinkThumbAnimated:YES];

    }
}

-(void) setTrackOn:(BOOL) on {
    [self.track setOn: on];
}
-(void) setTrackOn:(BOOL) on
          animated:(BOOL) animated {
    [self setTrackOn:on
            animated:animated
          completion:nil];
}
-(void) setTrackOn:(BOOL) on
          animated:(BOOL) animated
        completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration: kDefaultAnimationLength
                         animations: ^{
            [self setTrackOn: on];
        } completion: completion];
    }
    else [self setTrackOn: on];
}

-(void) moveThumbToPositionOn:(BOOL) on {
    CGRect newThumbFrame = self.thumb.frame;
    newThumbFrame.origin.x = on ? self.bounds.size.width : 0;
    [self.thumb setFrame: newThumbFrame];
}

-(void) moveThumbToPositionOn:(BOOL) on
                     animated:(BOOL)animated {
    [self moveThumbToPositionOn:on
                       animated:animated
                     completion:nil];
}
-(void) moveThumbToPositionOn:(BOOL) on
                     animated:(BOOL)animated
                   completion:(void (^)(BOOL finished))completion {
    
    if (animated) {
        __weak KLSwitch* weakSelf = self;
        [UIView animateWithDuration:kDefaultAnimationLength animations:^{
            [weakSelf moveThumbToPositionOn: on];
        } completion: completion];
    }
    else {
        [self moveThumbToPositionOn: on];
    }
}

#pragma mark - Event Handlers

-(void) toggleState {
    [self setOn: self.isOn ? NO : YES
       animated: YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (animated) {
        
        [self moveThumbToPositionOn:on
                           animated:animated];
        [self setTrackOn:on
                animated:animated];
    }
    if (!on) {
        [self.track shrinkContrastView];
    }
    if (_on != on) {
        _on = on;
        //Trigger the completion block if exists
        if (self.didChangeHandler) {
            self.didChangeHandler(_on);
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
- (void) setOn:(BOOL)on {
    //Perform the state change if different than current
    [self setOn: on
       animated: NO];
}

#pragma  mark - UIControl subclassed methods

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

@end


@implementation KLSwitchKnob

-(void) setFrame:(CGRect)frame {
    //Intercept the incoming frame and check if i would be drawn out of parent bounds
    
    if (frame.origin.x < kKnobOffset)
        frame.origin.x = kKnobOffset;
    
    if (self.superview) {
        CGFloat maxHorizontalCoordinate = self.superview.bounds.size.width - 2*kKnobOffset - self.bounds.size.width;
        if (frame.origin.x > maxHorizontalCoordinate)
            frame.origin.x = maxHorizontalCoordinate;
    }
    
    [super setFrame: frame];
}
-(BOOL) isTracking {
    return  self.bounds.size.height != self.bounds.size.width;
}
@end

@interface KLSwitchTrack ()
@property (nonatomic, strong) UIView* contrastView;
@end
@implementation KLSwitchTrack

-(id) initWithFrame:(CGRect)frame
            onColor:(UIColor*) onColor
           offColor:(UIColor*) offColor
      contrastColor:(UIColor*) contrastColor {
    if (self = [super initWithFrame: frame]) {
        _onTintColor = onColor;
        _tintColor = offColor;
        
        //Configure appearance of self
        
        _contrastView = [[UIView alloc] initWithFrame:frame];
        [_contrastView setBackgroundColor: contrastColor];
        [_contrastView setCenter: self.center];
        [self addSubview: _contrastView];
        
        CGFloat cornerRadius = frame.size.height/2.0f;
        [self.layer setCornerRadius: cornerRadius];
        [_contrastView.layer setCornerRadius: cornerRadius];
        [self.layer setBorderWidth: 1.5];
        [self.layer setBorderColor: [kDefaultTrackOffColor CGColor]];
    }
    return self;
}
-(void) setOn:(BOOL)on {
    if (on) {
        [self.layer setBorderColor: [self.onTintColor CGColor]];
        [self setBackgroundColor: self.onTintColor];
    }
    else {
        [self.layer setBorderColor: [self.tintColor CGColor]];
        [self setBackgroundColor: self.tintColor];
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
