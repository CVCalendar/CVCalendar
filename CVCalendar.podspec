Pod::Spec.new do |s|

s.name         = "CVCalendar"
s.version      = "1.2.0"
s.summary      = "A custom visual calendar for iOS 8 written in Swift."
s.homepage     = "https://github.com/Mozharovsky/CVCalendar"
s.screenshot  = "https://raw.githubusercontent.com/Mozharovsky/CVCalendar/master/Screenshots/CVCalendar_White.png"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Eugene Mozharovsky" => "mozharovsky@live.com" }
s.social_media_url   = "https://twitter.com/DottieYottie"
s.platform     = :ios, "8.0"
s.ios.deployment_target = "8.0"
s.source       = { :git => "https://github.com/Mozharovsky/CVCalendar.git", :tag => s.version }
s.source_files  = "CVCalendar/*.swift"
s.requires_arc = true

end
