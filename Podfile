source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

target 'MTP' do

  pod 'Anchorage'
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
  pod 'Moya', :inhibit_warnings => true
  pod 'Parchment'
  pod 'R.swift'
  pod 'SwiftLint'
  pod 'SwiftyBeaver'

  target 'MTPTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MTPUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

plugin 'cocoapods-acknowledgements',
    :settings_bundle => true,
    :exclude => [
        'SwiftLint',
    ]
