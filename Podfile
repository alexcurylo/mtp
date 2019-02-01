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

# avoid Validate Project Settings warnings with AppCenter/Distribute (1.13.0)
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'AppCenter-AppCenterDistributeResources'
            target.build_configurations.each do |config|
                config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.suppress.warnings'
            end
        end
    end
end
