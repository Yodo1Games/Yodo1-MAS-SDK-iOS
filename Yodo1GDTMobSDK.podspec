Pod::Spec.new do |s|
  s.name             = 'Yodo1GDTMobSDK'
  s.version          = '4.12.4'
  s.summary          = 'Yodo1GDTMobSDK'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-MAS-SDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.xcconfig = {"OTHER_LDFLAGS" => "-ObjC", "VALID_ARCHS"=>"arm64 arm64e armv7 armv7s x86_64", "VALID_ARCHS[sdk=iphoneos*]" => "arm64 arm64e armv7 armv7s", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64","HEADER_SEARCH_PATHS": "$(SDKROOT)/usr/include/libxml2"}
  
  s.source_files = s.name + '/*.h'
  
  s.public_header_files = s.name + '/*.h'
  
  s.frameworks = 'StoreKit', 'Security','CoreTelephony', 'AdSupport','CoreLocation', 'QuartzCore' ,'SystemConfiguration', 'AVFoundation'
  
  s.weak_frameworks = 'WebKit'
  
  s.libraries = 'xml2', 'z'

  s.vendored_libraries = s.name + '/*.a'

end
