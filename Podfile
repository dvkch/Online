source 'https://github.com/CocoaPods/Specs.git'

platform :osx, '10.13'

inhibit_all_warnings!

target 'Online' do    
    pod 'SYProxy'
    pod 'CLColorPicker', :podspec => './Podspecs/CLColorPicker.podspec'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
        end
    end
end
