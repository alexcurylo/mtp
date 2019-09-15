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

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do
  pod 'AlamofireNetworkActivityIndicator'
  pod 'Anchorage'
  pod 'AXPhotoViewer/Nuke'
  pod 'AXStateButton', :modular_headers => true
  pod 'Bolts', :modular_headers => true, :inhibit_warnings => true
  pod 'Crashlytics'
  pod 'Connectivity'
  pod 'DropDown'
  pod 'Fabric'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
  pod 'Firebase/Analytics'
  pod 'FLAnimatedImage', :modular_headers => true, :inhibit_warnings => true
  pod 'JWTDecode'
  pod 'KRProgressHUD'
  pod 'Moya'
  pod 'Nuke'
  pod 'Nuke-Alamofire-Plugin'
  pod 'Parchment', :inhibit_warnings => true
  pod 'R.swift'
  pod 'R.swift.Library'
  pod 'Realm', :modular_headers => true
  pod 'RealmSwift'
  pod 'SwiftEntryKit', :inhibit_warnings => true
  pod 'SwiftLint'
  pod 'SwiftyBeaver'

  target 'MTPTests' do
    inherit! :search_paths
  end

  target 'MTPUITests' do
    inherit! :search_paths
  end

end

plugin 'cocoapods-acknowledgements',
    :settings_bundle => true,
    :exclude => [
        'SwiftLint',
    ]

post_install do |installer|
    installer.pods_project.targets.each do |target|
        # patch SwiftLint
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end
