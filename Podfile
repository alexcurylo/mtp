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
# https://github.com/facebook/facebook-swift-sdk/issues/491
# https://github.com/firebase/firebase-ios-sdk/issues/3136
# https://github.com/auth0/JWTDecode.swift/issues/92

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do
  pod 'Anchorage'
  pod 'Crashlytics'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
  pod 'FBSDKShareKit', :modular_headers => true
  pod 'Firebase/Analytics'
  pod 'JWTDecode'

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
