source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks!

def available_pods
  
    pod 'RaxelPulse', '6.0.4'
    pod 'Firebase/Core', '8.6.0'
    pod 'Firebase/Database', '8.6.0'
    pod 'Firebase/Auth', '8.6.0'
    pod 'Firebase/Storage', '8.6.0'
    pod 'AFNetworking', '4.0.1'
    pod 'JSONModel', '1.8.0'
    pod 'CocoaLumberjack/Swift', '3.8.5'
    pod 'SDWebImage', '5.19.7'
    pod 'GKImagePicker@robseward', '0.0.9'
    pod 'SystemServices', '2.0.1'
    pod 'CMTabbarView', '0.2.0'
    pod 'SHSPhoneComponent', '2.32'
    pod 'libPhoneNumber-iOS', '1.2.0'
    pod 'IQDropDownTextField' #, '4.5.0'
    pod 'IQMediaPickerController', '2.0.0'
    pod 'KDLoadingView', '1.0.5'
    pod 'YYWebImage', '1.0.5'
    pod 'UICountingLabel', '1.4.1'
    pod 'UIActionSheet+Blocks', '0.9'
    pod 'UIAlertView+Blocks', '0.9'
    pod "RMessage", '2.3.4'
    pod 'GoogleMaps', '7.4.0'
    pod 'GooglePlaces', '7.4.0'
    pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord'
    pod 'DKImagePickerController', '4.3.9'

end


target 'TelematicsApp' do
    available_pods
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end

