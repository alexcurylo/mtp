source 'https://github.com/CocoaPods/Specs.git'

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do

  pod 'Anchorage'
  pod 'AppCenter'
  pod 'AppCenter/Distribute'
  pod 'Bolts', :modular_headers => true, :inhibit_warnings => true
  pod 'FacebookCore', :inhibit_warnings => true
  pod 'FacebookLogin'
  pod 'FacebookShare', :inhibit_warnings => true
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
  pod 'FBSDKShareKit', :modular_headers => true, :inhibit_warnings => true
  pod 'JWTDecode'
  pod 'KRProgressHUD'
  pod 'Moya'
  pod 'Nuke'
  pod 'Parchment'
  pod 'Realm', :modular_headers => true
  pod 'RealmSwift'
  pod 'R.swift'
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
        target.build_configurations.each do |config|
            # patch SwiftLint
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end
