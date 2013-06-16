Pod::Spec.new do |s|
  s.name         	= "KLSwitch"
  s.version      	= "0.0.1"
  s.platform		= :ios, '4.3'
  s.summary      	= "A control that organizes multiple navigation controllers in a stack inspired by Evernote 5.0 app"
  s.homepage     	= "http://www.cocoacontrols.com/platforms/ios/controls/klnoteviewcontroller"
  s.license      	= 'Apache 2.0'
  s.author       	= { "Kieran Lafferty" => "kieran.lafferty@gmail.com"}
  s.source       	= { :git => "https://github.com/KieranLafferty/KLSwitch.git" }
  s.source_files 	= 'KLSwitch/KLSwitch/*.{h,m}'
  s.requires_arc 	= true
  s.frameworks  	= 'QuartzCore'
  s.frameworks  	= 'UIKit'
end