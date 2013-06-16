KLSwitch
=======

<img src="https://raw.github.com/KieranLafferty/KLNoteViewController/master/KLSwitch/Screenshot.png" width="50%"/>

An iOS 7 UISwitch clone that works on iOS 5+

Requires ARC



<!-- MacBuildServer Install Button -->
<div class="macbuildserver-block">
    <a class="macbuildserver-button" href="http://macbuildserver.com/project/github/build/?xcode_project=KLNoteViewController.xcodeproj&amp;target=KLNoteViewController&amp;repo_url=https%3A%2F%2Fgithub.com%2FKieranLafferty%2FKLNoteViewController&amp;build_conf=Release" target="_blank"><img src="http://com.macbuildserver.github.s3-website-us-east-1.amazonaws.com/button_up.png"/></a><br/><sup><a href="http://macbuildserver.com/github/opensource/" target="_blank">by MacBuildServer</a></sup>
</div>
<!-- MacBuildServer Install Button -->


## Installation ##


	1. Drag the KLSwitch.xcodeproj to your existing project
	2. Under Build Phases on your project's Xcode Project file add 'KLSwitch(KLSwitch)' to your Target Dependancies
	3. Under Build on your Xcode Project file add 'libKLSwitch' & QuartzCore.framework under Link Binary With Libraries
	4. Include #import <KLSwitch/KLSwitch.h> in any file you wish to use
	
	
Via CocoaPods
Add the following line to your podfile

	pod 'KLSwitch', :git=>'git://github.com/KieranLafferty/KLSwitch.git'
## Usage ##

See Demo project for sample usage using Interface Builder


## Config ##
The visual appearance can be tweaked by changing the constants in <code>KLNoteViewController.m</code>:

	#define kSwitchTrackOnColor     [UIColor colorWithRed:83/255.0 green: 214/255.0 blue: 105/255.0 alpha: 1]
	#define kSwitchTrackOffColor    [UIColor colorWithWhite: 0.9 alpha:1.0]
	#define kSwitchTrackContrastColor [UIColor whiteColor]

	#define kDefaultSwitchBorderWidth 2.0
	//Size of knob with respect to the control - Must be a multiple of 2
	#define kKnobOffset 2.0
	#define kKnobTrackingGrowthRatio 1.2

	#define kDefaultAnimationScaleLength 0.10
	#define kDefaultAnimationSlideLength 0.20
	#define kDefaultAnimationThumbGrowLength 0.20

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