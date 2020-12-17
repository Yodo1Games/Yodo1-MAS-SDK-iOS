#
# Be sure to run `pod lib lint Yodo1AdvertAdMob.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasMediationUnityAds'
  s.version          = '0.0.0.1-beta'
  s.summary          = 'Yodo1MasMediationUnityAds'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Yodo1/Yodo1MasMediationUnityAds'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouYuzhen' => 'zhouyuzhen@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1/Yodo1MasMediationUnityAds.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  # s.static_framework = true

  s.source_files = 'Yodo1MasMediationUnityAds/Classes/**/*'
  
  s.resource_bundles = {
    'Yodo1MasMediationUnityAds' => ['Yodo1MasMediationUnityAds/Assets/*']
  }
  # s.resources = 'Yodo1MasMediationUnityAds/Assets/*.strings', 'Yodo1MasMediationUnityAds/Assets/*.xcassets'

  # s.public_header_files = 'Pod/Classes/**/*.h's
  # s.frameworks = 'UIKit'
  
  s.dependency 'Yodo1MasCore'
  s.dependency 'UnityAds','~> 3.5.1'
  
end
