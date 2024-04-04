Pod::Spec.new do |s|
  s.name             = 'Castle'
  s.version          = '3.0.9'
  s.summary          = 'Castle SDK for iOS'

  s.description      = <<-DESC
Castle for iOS provides a simple way to integrate Castle into your app.
                       DESC

  s.homepage         = 'https://castle.io'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Castle Intelligence' => 'team@castle.io' }
  s.source           = { :git => 'https://github.com/castle/castle-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/castle_io'

  s.platform = :ios
  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.ios.frameworks = 'Security', 'CoreTelephony', 'UIKit', 'SystemConfiguration', 'CoreMotion', 'CoreLocation'
  s.ios.vendored_frameworks = 'Castle/Highwind.xcframework', 'Castle/GeoZip.xcframework'

  s.source_files = 'Castle/{Internal,Public}/*{h,m}'
  s.resource_bundles = {"Castle" => ["Castle/PrivacyInfo.xcprivacy"]}
  s.swift_version = '5.2'
end
