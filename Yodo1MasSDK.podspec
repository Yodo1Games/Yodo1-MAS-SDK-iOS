#
# Be sure to run `pod lib lint Yodo1MasSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasSDK'
  s.version          = '0.0.0.10-beta'
  s.summary          = 'Yodo1MasSDK'
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
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouYuzhen' => 'zhouyuzhen@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS.git', :tag => s.version.to_s }
  s.xcconfig = {"OTHER_LDFLAGS" => "-ObjC", "VALID_ARCHS"=>"arm64 arm64e armv7 armv7s x86_64", "VALID_ARCHS[sdk=iphoneos*]" => "arm64 arm64e armv7 armv7s", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64"}
  s.ios.deployment_target = '9.0'
  s.source_files = 'Yodo1MasSDK/Classes/**/*'
  s.public_header_files = 'Yodo1MasSDK/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Yodo1MasCore', '0.0.0.9-beta'
  s.dependency 'Yodo1MasMediationAdMobMax', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationAdMob', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationApplovinMax', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationApplovin', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationIronSourceMax', '0.0.0.8-beta'
  s.dependency 'Yodo1MasMediationIronSource', '0.0.0.8-beta'
  s.dependency 'Yodo1MasMediationFacebook', '0.0.0.6-beta'
  #s.dependency 'Yodo1MasMediationInMobi', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationTapjoy', '0.0.0.6-beta'
  s.dependency 'Yodo1MasMediationUnityAds', '0.0.0.7-beta'
  s.dependency 'Yodo1MasMediationVungle', '0.0.0.7-beta'
  
end
