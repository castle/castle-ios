#
# Be sure to run `pod lib lint Castle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Castle'
  s.version          = '1.0.3'
  s.summary          = 'Castle SDK for iOS'

  s.description      = <<-DESC
Castle for iOS provides a simple way to integrate Castle into your app.
                       DESC

  s.homepage         = 'https://castle.io'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Castle Intelligence' => 'team@castle.io' }
  s.source           = { :git => 'https://github.com/castle/castle-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/castle_io'

  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'Security', 'CoreTelephony', 'UIKit', 'SystemConfiguration'

  s.source_files = 'Castle/Classes/**/*'
end


