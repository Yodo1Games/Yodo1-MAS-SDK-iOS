#
# Be sure to run `pod lib lint Yodo1MasMediationApplovinMax.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasMediationApplovinMax'
  s.version          = '0.0.0.20-beta'
  s.summary          = 'Yodo1MasMediationApplovinMax'
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
  

  s.ios.deployment_target = '9.0'

  s.source_files = 'Yodo1MasMediationApplovinMax/Classes/**/*'
  s.public_header_files = 'Yodo1MasMediationApplovinMax/Classes/**/*.h'
  s.vendored_frameworks = 'Yodo1MasMediationApplovinMax/Lib/**/*.framework'
  s.dependency 'Yodo1MasMediationAdMob'
  s.dependency 'Yodo1MasMediationApplovin'
  s.dependency 'Yodo1MasMediationIronSource'
  s.dependency 'Yodo1MasMediationFacebook'
  #s.dependency 'Yodo1MasMediationInMobi'
  s.dependency 'Yodo1MasMediationTapjoy'
  s.dependency 'Yodo1MasMediationUnityAds'
  s.dependency 'Yodo1MasMediationVungle'
  
  # s.dependency 'AppLovinMediationGoogleAdapter'
  # s.dependency 'AppLovinMediationIronSourceAdapter'
  # s.dependency 'AppLovinMediationFacebookAdapter'
  # s.dependency 'AppLovinMediationInMobiAdapter'
  # s.dependency 'AppLovinMediationTapjoyAdapter'
  # s.dependency 'AppLovinMediationUnityAdsAdapter'
  # s.dependency 'AppLovinMediationVungleAdapter'
  
end
