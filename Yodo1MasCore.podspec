#
# Be sure to run `pod lib lint Yodo1MasCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yodo1MasCore'
  s.version          = '4.0.2.2'
  s.summary          = 'Yodo1MasCore for iOS'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why poddid you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Yodo1MasCore
                       DESC

  s.homepage         = 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS.git', :tag => s.version.to_s }
  s.static_framework = true
  s.ios.deployment_target = '9.0'
  s.info_plist = {
    'AppLovinSdkKey' => 'xcGD2fy-GdmiZQapx_kUSy5SMKyLoXBk8RyB5u9MVv34KetGdbl4XrXvAUFy0Qg9scKyVTI0NM4i_yzdXih4XE',
    'SKAdNetworkItems' => [
    {'SKAdNetworkIdentifier' => '275upjj5gd.skadnetwork'},
    {'SKAdNetworkIdentifier' => '2u9pt9hc89.skadnetwork'},
    {'SKAdNetworkIdentifier' => '3rd42ekr43.skadnetwork'},
    {'SKAdNetworkIdentifier' => '4468km3ulz.skadnetwork'},
    {'SKAdNetworkIdentifier' => '44jx6755aq.skadnetwork'},
    {'SKAdNetworkIdentifier' => '4fzdc2evr5.skadnetwork'},
    {'SKAdNetworkIdentifier' => '4pfyvq9l8r.skadnetwork'},
    {'SKAdNetworkIdentifier' => '5lm9lj6jb7.skadnetwork'},
    {'SKAdNetworkIdentifier' => '6g9af3uyq4.skadnetwork'},
    {'SKAdNetworkIdentifier' => '7rz58n8ntl.skadnetwork'},
    {'SKAdNetworkIdentifier' => '7ug5zh24hu.skadnetwork'},
    {'SKAdNetworkIdentifier' => '8s468mfl3y.skadnetwork'},
    {'SKAdNetworkIdentifier' => '9nlqeag3gk.skadnetwork'},
    {'SKAdNetworkIdentifier' => '9rd848q2bz.skadnetwork'},
    {'SKAdNetworkIdentifier' => '9t245vhmpl.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'c6k4g5qg8m.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'cg4yq2srnc.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ejvt5qm6ak.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'g28c52eehv.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'hs6bdukanm.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'klf5c3l5u5.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'm8dbw4sv7c.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'mlmmfzh3r3.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'mtkv5xtk9e.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ppxm28t8ap.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'prcb7njmu6.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'rx5hdcabgc.skadnetwork'},
    {'SKAdNetworkIdentifier' => 't38b2kh725.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'tl55sbb4fm.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'u679fj5vs4.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'uw77j35x4d.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'v72qych5uu.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'yclnxrl5pm.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'cstr6suwn9.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'av6w8kgt66.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'f38h382jlk.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'kbd757ywx3.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ludvb6z3bs.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'wzmmz9fp6w.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ydx93a7ass.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'n38lu8286q.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'v9wttpbfk9.skadnetwork'},
    {'SKAdNetworkIdentifier' => '24t9a8vw3c.skadnetwork'},
    {'SKAdNetworkIdentifier' => '252b5q8x7y.skadnetwork'},
    {'SKAdNetworkIdentifier' => '3qy4746246.skadnetwork'},
    {'SKAdNetworkIdentifier' => '3sh42y64q3.skadnetwork'},
    {'SKAdNetworkIdentifier' => '5a6flpkh64.skadnetwork'},
    {'SKAdNetworkIdentifier' => '5l3tpt7t6e.skadnetwork'},
    {'SKAdNetworkIdentifier' => '9g2aggbj52.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'dzg6xy7pwj.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'f73kdq92p3.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'hdw39hrw9y.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'wg4vff78zm.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'y45688jllp.skadnetwork'},
    {'SKAdNetworkIdentifier' => '424m5254lk.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ggvn48r87g.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'p78axxw29g.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'w9q455wk68.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'su67r6k2v3.skadnetwork'},
    {'SKAdNetworkIdentifier' => '6xzpu9s2p8.skadnetwork'},
    {'SKAdNetworkIdentifier' => '737z793b9f.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'glqzh8vgby.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'n9x2a789qt.skadnetwork'},
    {'SKAdNetworkIdentifier' => '578prtvx9j.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'ecpz2srf59.skadnetwork'},
    {'SKAdNetworkIdentifier' => '22mmun2rn5.skadnetwork'},
    {'SKAdNetworkIdentifier' => '238da6jt44.skadnetwork'},
    {'SKAdNetworkIdentifier' => '44n7hlldy6.skadnetwork'},
    {'SKAdNetworkIdentifier' => '488r3q3dtq.skadnetwork'},
    {'SKAdNetworkIdentifier' => '4dzt52r2t5.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'bvpn9ufa9b.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'lr83yxwka7.skadnetwork'},
    {'SKAdNetworkIdentifier' => 's39g8k73mm.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'v79kvwwj4g.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'zmvfpc5aq8.skadnetwork'},
    {'SKAdNetworkIdentifier' => 'gta9lk7p23.skadnetwork'}
    ]
  }
  s.xcconfig = {"OTHER_LDFLAGS" => "-ObjC", "VALID_ARCHS"=>"arm64 arm64e armv7 armv7s x86_64", "VALID_ARCHS[sdk=iphoneos*]" => "arm64 arm64e armv7 armv7s", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64"}
  s.source_files = s.name + '/Classes/**/*'
  s.public_header_files = s.name + '/Classes/**/*.h'
  #s.vendored_frameworks = s.name + '/Lib/**/*.framework'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking'
  s.dependency 'YYModel'
  s.dependency 'Yodo1SaAnalytics'
  
end
