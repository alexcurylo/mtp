source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

target 'MTP' do

  pod 'AppCenter'
  pod 'AppCenter/Distribute'
  pod 'SwiftLint'

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
