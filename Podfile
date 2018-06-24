source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
#use_frameworks!
#inhibit_all_warnings!

target 'MTP' do

  pod 'AppCenter'
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

#plugin 'cocoapods-acknowledgements',
#    :settings_bundle => true,
#    :exclude => [
#        'SwiftLint',
#    ],
#    :settings_post_process => Proc.new { |settings_plist_path, umbrella_target|
#        File.delete settings_plist_path unless umbrella_target.cocoapods_target_label == 'Pods-Agoda.Consumer'
#        # TODO: to be removed after merging https://github.com/CocoaPods/cocoapods-acknowledgements/pull/43
#        [settings_plist_path, "Pods/#{File.basename settings_plist_path.sub('-settings', '')}"]
#            .map(&umbrella_target.user_project.main_group['Pods'].method(:find_file_by_path))
#            .reject(&:nil?)
#            .map(&:remove_from_project)
#        umbrella_target.user_project.save
#    }
