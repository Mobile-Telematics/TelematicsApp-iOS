source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

def available_pods
  
    pod 'RaxelPulse', '5.10' #OUR NEW SDK 5.10 RELEASE
    pod 'HEREMaps'
    pod 'Firebase/Core'
    pod ‘Firebase/Database’
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'AFNetworking'
    pod 'JSONModel'
    pod 'CocoaLumberjack/Swift'
    pod 'SDWebImage', '5.9.0'
    pod 'GKImagePicker@robseward'
    pod 'SystemServices'
    pod 'KVNProgress'
    pod 'UICountingLabel'
    pod 'UIActionSheet+Blocks'
    pod 'UIAlertView+Blocks'
    pod 'CMTabbarView', '0.2.0'
    pod 'YYWebImage'
    pod 'SHSPhoneComponent'
    pod "IQDropDownTextField"
    pod "RMessage"
    pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord'
    pod "IQMediaPickerController"
    pod 'libPhoneNumber-iOS', '~> 0.8'
    pod 'KDLoadingView'
    pod 'ImagePicker'
    pod 'CircleTimer', '0.2.0'
    pod 'GoogleMaps', '3.9.0'
    pod 'GooglePlaces', '3.9.0'

end


target 'TelematicsApp' do
    available_pods
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
        end
    end
end

