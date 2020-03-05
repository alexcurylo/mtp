using_bundler = defined? Bundler
unless using_bundler
  puts "\nPlease re-run using:".red
  puts "  bundle exec pod install\n\n"
  exit(1)
end

source 'https://cdn.cocoapods.org/'

# SPM progress:
# https://github.com/Rightpoint/Anchorage/pull/86
# https://github.com/firebase/firebase-ios-sdk/issues/3136

$iosVersion = '11.0'
platform :ios, $iosVersion

target 'MTP' do
  pod 'Anchorage'
  pod 'Crashlytics'
  pod 'Firebase/Analytics'

  target 'MTPTests' do
    inherit! :search_paths
  end

  target 'MTPUITests' do
    inherit! :search_paths
  end

end

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
