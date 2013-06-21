KLSwitch
=======
An iOS 7 UISwitch clone that works on iOS 5+

https://www.cocoacontrols.com/controls/klswitch

<img src="https://raw.github.com/KieranLafferty/KLSwitch/master/Screenshot.png" width="50%"/>

Requires ARC


<!-- MacBuildServer Install Button -->
<div class="macbuildserver-block">
    <a class="macbuildserver-button" href="http://macbuildserver.com/project/github/build/?xcode_project=KLSwitchDemo.xcodeproj&amp;target=KLSwitchDemo&amp;repo_url=https%3A%2F%2Fgithub.com%2FKieranLafferty%2FKLSwitch.git&amp;build_conf=Release" target="_blank"><img src="http://com.macbuildserver.github.s3-website-us-east-1.amazonaws.com/button_up.png"/></a><br/><sup><a href="http://macbuildserver.com/github/opensource/" target="_blank">by MacBuildServer</a></sup>
</div>
<!-- MacBuildServer Install Button -->
## Goal ##
1. Create the iOS 7 UISwitch to be compatible with iOS 5+
2. Create a drop in replacement for UISwitch


## Installation ##


	1. Drag the KLSwitch.xcodeproj to your existing project
	2. Under Build Phases on your project's Xcode Project file add 'KLSwitch(KLSwitch)' to your Target Dependancies
	3. Under Build on your Xcode Project file add 'libKLSwitch' & QuartzCore.framework under Link Binary With Libraries
	4. Include #import <KLSwitch/KLSwitch.h> in any file you wish to use
	
	
Via CocoaPods
Add the following line to your podfile

	pod 'KLSwitch'
	
## Usage ##
Interface is exactly the same as for the regular UISwitch you know and love (http://developer.apple.com/library/ios/#documentation/uikit/reference/UISwitch_Class/Reference/Reference.html)

Added an event handler block to recieve state changes when the switch is toggled on/off which can be set as follows:

	mySwitch.didChangeHandler = ^(BOOL isOn) {
		//Do something useful with it here
	}
	
Or it can be set using the custom initializer
	
	- (id)initWithFrame:(CGRect)frame
	   didChangeHandler:(changeHandler) didChangeHandler;
	   
	   
See Demo project for sample usage using Interface Builder


## Config ##
The visual appearance can be tweaked by changing the constants in <code>KLNoteViewController.m</code>:

	//Appearance Defaults - Colors
	//Track Colors
	#define kDefaultTrackOnColor     [UIColor colorWithRed:83/255.0 green: 214/255.0 blue: 105/255.0 alpha: 1]
	#define kDefaultTrackOffColor    [UIColor colorWithWhite: 0.9 alpha:1.0]
	#define kDefaultTrackContrastColor [UIColor whiteColor]

	//Thumb Colors
	#define kDefaultThumbTintColor [UIColor whiteColor]
	#define kDefaultThumbBorderColor [UIColor colorWithWhite: 0.9 alpha:1.0]

	//Appearance - Layout

	//Size of knob with respect to the control - Must be a multiple of 2
	#define kKnobOffset 2.0
	#define kKnobTrackingGrowthRatio 1.2                //Amount to grow the thumb on press down

	#define kDefaultPanActivationThreshold 0.7                    //Number between 0.0 - 1.0 describing how far user must drag before initiating the switch

	//Appearance - Animations
	#define kDefaultAnimationScaleLength 0.10           //Length of time for the thumb to grow on press down
	#define kDefaultAnimationSlideLength 0.25           //Length of time to slide the thumb from left/right to right/left

	#define kSwitchTrackContrastViewShrinkFactor 0.00   



## Contact ##

* [@kieran_lafferty](https://twitter.com/kieran_lafferty) on Twitter
* [@kieranlafferty](https://github.com/kieranlafferty) on Github
* <a href="mailTo:kieran.lafferty@gmail.com">kieran.lafferty [at] gmail [dot] com</a>

## License ##

Copyright (c) 2012 Kieran Lafferty

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.