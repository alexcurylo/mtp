source 'https://github.com/CocoaPods/Specs.git'

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do

  pod 'Anchorage', :inhibit_warnings => true
  pod 'AppCenter'
  pod 'AppCenter/Distribute'
  pod 'Bolts', :modular_headers => true, :inhibit_warnings => true
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare', :inhibit_warnings => true
  pod 'FBSDKCoreKit', :modular_headers => true, :inhibit_warnings => true
  pod 'FBSDKLoginKit', :modular_headers => true, :inhibit_warnings => true
  pod 'FBSDKShareKit', :modular_headers => true, :inhibit_warnings => true
  pod 'JWTDecode'
  pod 'Moya', '~> 12.0.0-beta', :inhibit_warnings => true
  pod 'Parchment'
  pod 'R.swift', '~> 5.0.0.alpha'
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

# avoid 'set to 7.0' warnings in Xcode 10
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iosVersion
        end
    end
end
