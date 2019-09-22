using_bundler = defined? Bundler
unless using_bundler
  puts "\nPlease re-run using:".red
  puts "  bundle exec pod install\n\n"
  exit(1)
end

source 'https://cdn.cocoapods.org/'

# Xcode 11 "Multiple commands produce Assets.car" error?
# Add ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Assets.car to [CP] Copy Pods Resources phase's input files
# (blown away on every `pod install`)
# https://github.com/CocoaPods/CocoaPods/issues/8122

# http://blog.cocoapods.org/CocoaPods-1.7.0-beta/
#install! 'cocoapods', :generate_multiple_pod_projects => true

# SPM progress:
# https://github.com/Rightpoint/Anchorage/pull/86
# https://github.com/AssistoLab/DropDown
# https://github.com/facebook/facebook-swift-sdk/issues/491
# https://github.com/firebase/firebase-ios-sdk/issues/3136
# https://github.com/auth0/JWTDecode.swift/pull/93
# https://github.com/krimpedance/KRProgressHUD
# https://github.com/rechsteiner/Parchment
# R.swift is pending release of 5.1

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do
  pod 'Anchorage'
  pod 'Bolts', :modular_headers => true, :inhibit_warnings => true
  pod 'Crashlytics'
  pod 'DropDown'
  pod 'Fabric'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
  pod 'Firebase/Analytics'
  pod 'JWTDecode'
  pod 'KRProgressHUD'
  pod 'Parchment', :inhibit_warnings => true
  pod 'R.swift'
  pod 'R.swift.Library'

  target 'MTPTests' do
    inherit! :search_paths
  end

  target 'MTPUITests' do
    inherit! :search_paths
  end

end

plugin 'cocoapods-acknowledgements', :settings_bundle => true

post_install do |installer|
    installer.pods_project.targets.each do |target|
        # patch Crashlytics, Fabric, nanopb
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end
