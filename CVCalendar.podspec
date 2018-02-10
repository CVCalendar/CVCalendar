Pod::Spec.new do |s|

s.name         = 'CVCalendar'
s.version      = '1.6.1'
s.summary      = 'A custom visual calendar for iOS 8+ written in Swift (4.0).'
s.homepage     = 'https://github.com/CVCalendar/CVCalendar'
s.screenshot  = 'https://raw.githubusercontent.com/CVCalendar/CVCalendar/master/Screenshots/CVCalendar_White.png'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors             = { 'Eugene Mozharovsky' => 'mozharovsky@live.com', 'Jonas-Taha El Sesiy' => 'info@elsesiy.com' }
s.platform     = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.source       = { :git => 'https://github.com/CVCalendar/CVCalendar.git', :tag => s.version }
s.source_files  = 'CVCalendar/*.swift'
s.requires_arc = true
s.swift_version = '4.0'

end
