#
# Be sure to run `pod lib lint Yodo1AdvertAdMob.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasMediationApplovin'
  s.version          = '0.0.0.4-beta'
  s.summary          = 'Yodo1MasMediationApplovin'
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

  s.source_files = 'Yodo1MasMediationApplovin/Classes/**/*'
  
#  s.resource_bundles = {
#    'Yodo1MasMediationApplovin' => ['Yodo1MasMediationApplovin/Assets/*']
#  }
  # s.resources = 'Yodo1MasMediationApplovin/Assets/*.strings', 'Yodo1MasMediationApplovin/Assets/*.xcassets'

  # s.public_header_files = 'Pod/Classes/**/*.h's
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Yodo1MasCore', '>= 0.0.0.4-beta'
  s.dependency 'AppLovinSDK','~> 6.14.6'
  s.dependency 'AppLovinMediationGoogleAdapter','~> 7.67.1.5'
  s.dependency 'AppLovinMediationIronSourceAdapter','~> 7.0.4.0.0'
  s.dependency 'AppLovinMediationFacebookAdapter','~> 6.2.0.1'
  s.dependency 'AppLovinMediationInMobiAdapter','~> 9.1.0.1'
  s.dependency 'AppLovinMediationTapjoyAdapter','~> 12.7.1.1'
  s.dependency 'AppLovinMediationUnityAdsAdapter','~> 3.5.1.0'
  s.dependency 'AppLovinMediationVungleAdapter','~> 6.8.1.2'
  
end
