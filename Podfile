source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

def available_pods
  
    pod 'RaxelPulse', '5.16' #TELEMATICS SDK 5.16 NEW RELEASE JUNE 2022
    pod 'Firebase/Core', '8.6.1'
    pod ‘Firebase/Database’
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'AFNetworking'
    pod 'JSONModel'
    pod 'CocoaLumberjack/Swift'
    pod 'SDWebImage', '5.9.0'
    pod 'GKImagePicker@robseward'
    pod 'SystemServices'
    pod 'CMTabbarView', '0.2.0'
    pod 'SHSPhoneComponent'
    pod 'libPhoneNumber-iOS', '~> 0.8'
    pod "IQDropDownTextField"
    pod "IQMediaPickerController"
    pod 'KDLoadingView'
    pod 'YYWebImage'
    pod 'UICountingLabel'
    pod 'UIActionSheet+Blocks'
    pod 'UIAlertView+Blocks'
    pod "RMessage", '2.3.4'
    pod 'CircleTimer', '0.2.0'
    pod 'GoogleMaps', '3.9.0'
    pod 'GooglePlaces', '3.9.0'
    pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord'
    pod 'ImagePicker', :git => 'https://github.com/hyperoslo/ImagePicker.git'

end


target 'TelematicsApp' do
    available_pods
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
    end
end

