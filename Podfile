# Uncomment the next line to define a global platform for your project
  platform :ios, '14.0'
use_frameworks!

target 'WhatTheCoffee' do
  project 'WhatTheCoffee'

    # NaverMap
    pod 'NMapsMap'

    # Firebase
    pod 'Firebase/Analytics'
    pod 'Firebase/Crashlytics'

    # JSON
    pod 'SwiftyJSON', '5.0.0'
	
	# Network
	pod 'Alamofire'

	# DB
	pod 'RealmSwift'

    # UI
    pod 'TextFieldEffects'
    pod 'IQKeyboardManagerSwift'
  
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end


