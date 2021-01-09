#
# Be sure to run `pod lib lint Yodo1MasMediationAdMob.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasMediationAdMob'
  s.version          = '0.0.0.2-beta'
  s.summary          = 'Yodo1MasMediationAdMob'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouYuzhen' => 'zhouyuzhen@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.xcconfig = {"OTHER_LDFLAGS" => "-ObjC", "VALID_ARCHS"=>"arm64 arm64e armv7 armv7s x86_64", "VALID_ARCHS[sdk=iphoneos*]" => "arm64 arm64e armv7 armv7s", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64"}
  s.source_files = 'Yodo1MasMediationAdMob/Classes/**/*'
  
#  s.resource_bundles = {
#    'Yodo1MasMediationAdMob' => ['Yodo1MasMediationAdMob/Assets/*']
#  }
  # s.resources = 'Yodo1MasMediationAdMob/Assets/*.strings', 'Yodo1MasMediationAdMob/Assets/*.xcassets'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Yodo1MasCore', '>= 0.0.0.2-beta'
  s.dependency 'Google-Mobile-Ads-SDK','~> 7.66.0'
  # s.dependency 'GoogleMobileAdsMediationAppLovin' #,'6.14.9.0'
  # s.dependency 'GoogleMobileAdsMediationIronSource' #,'7.0.3.0'
  # s.dependency 'GoogleMobileAdsMediationFacebook' #,'6.2.0.0'
  # s.dependency 'GoogleMobileAdsMediationInMobi' #,'9.1.1.0'
  # s.dependency 'GoogleMobileAdsMediationTapjoy' #,'12.7.1.0'
  # s.dependency 'GoogleMobileAdsMediationUnity' #,'3.5.1.1'
  # s.dependency 'GoogleMobileAdsMediationVungle' #,'6.8.1.0'
  
end
