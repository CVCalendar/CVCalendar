Pod::Spec.new do |s|

s.name         = 'CVCalendar'
s.version      = '1.7.0'
s.summary      = 'A custom visual calendar for iOS 8+ written in Swift (>= 4.0).'
s.homepage     = 'https://github.com/CVCalendar/CVCalendar'
s.screenshot  = 'https://raw.githubusercontent.com/CVCalendar/CVCalendar/master/Screenshots/CVCalendar_White.png'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors             = { 'Eugene Mozharovsky' => 'mozharovsky@live.com', 'Jonas-Taha El Sesiy' => 'github@elsesiy.com' }
s.platform     = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.source       = { :git => 'https://github.com/CVCalendar/CVCalendar.git', :tag => s.version }
s.source_files  = 'CVCalendar/*.swift'
s.requires_arc = true

if s.respond_to?(:swift_versions) then
  s.swift_versions = ['4.2', '5.0']
else
  s.swift_version = '4.2'
end

end
