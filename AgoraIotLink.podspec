#
# Be sure to run `pod lib lint AgoraIotSdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraIotLink'
  s.version          = '1.3.0.1'
  s.summary          = 'AgoraIotLink for iot development.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/ag-iot-ios-app'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'support' => 'support@agora.io' }
  s.source           = { :git => 'git@github.com:AgoraIO-Community/ag-iot-ios-app.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 arm64e' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64 i386 arm64' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64 i386 arm64' }

#  s.xcconfig = { "USER_HEADER_SEARCH_PATHS" => "$(PODS_ROOT)" }
#  s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}"' }
  s.ios.deployment_target = '12.0'
#  s.public_header_files = "AgoraIotLink/AgoraIotLink-Swift.h"
  s.source_files = 'AgoraIotLink/Source/**/*.{swift,h,m}'
  s.swift_version = '5.5'
  
  # s.resource_bundles = {
  #   'AgoraIotSdk' => ['AgoraIotSdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  # s.vendored_frameworks ='AgoraIotSdk/Libs/*.framework','AgoraIotSdk/Libs/*.xcframework'
  
  s.dependency 'Alamofire','5.6.0'
  s.dependency 'AWSMobileClient','2.27.6'
  s.dependency 'AWSIoT','2.27.6'
  s.dependency 'EMPush'
  s.dependency 'AgoraRtcEngine_iOS', '4.0.0-rc.1'
  s.dependency 'AgoraRtm_iOS','1.5.0'
end
