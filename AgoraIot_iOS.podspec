Pod::Spec.new do |spec|
   spec.name          = "AgoraIot_iOS"
   spec.version       = "1.0"
   spec.summary       = "Agora iOS video SDK"
   spec.description   = "iOS library for agora A/V communication, broadcasting and data channel service."
   spec.homepage      = "https://docs.agora.io/en/Agora%20Platform/downloads"
   spec.license       = { "type" => "Copyright", "text" => "Copyright 2018 agora.io. All rights reserved.\n"}
   spec.author        = { "Agora Lab" => "developer@agora.io" }
   spec.platform      = :ios
   spec.source        = { :git => "" }
   
   spec.vendored_frameworks =  ["iot_libs/*.framework", "iot_libs/other_libs/*{.xcframework,framework}"]
   #spec.dependency 'Alamofire','5.6.0'
   
   spec.requires_arc  = true
   spec.ios.deployment_target  = '12.0'
 end
