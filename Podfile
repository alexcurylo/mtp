#source 'https://github.com/CocoaPods/Specs.git'
source 'https://cdn.cocoapods.org/'

# http://blog.cocoapods.org/CocoaPods-1.7.0-beta/
#install! 'cocoapods', :generate_multiple_pod_projects => true

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do

  pod 'AlamofireNetworkActivityIndicator'
  pod 'Anchorage'
  pod 'AppCenter'
  pod 'Bolts', :modular_headers => true, :inhibit_warnings => true
  pod 'DropDown'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
  pod 'JWTDecode'
  pod 'KRProgressHUD'
  pod 'Moya'
  pod 'Nuke'
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
