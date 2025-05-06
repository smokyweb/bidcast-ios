# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BidCast' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Kingfisher'
  pod 'SVProgressHUD'
  pod 'IQKeyboardManagerSwift'
  pod 'FittedSheets'
  pod 'Toast-Swift'
  pod 'DropDown'
  pod 'SideMenu'
  pod 'CropViewController'
  pod 'FSCalendar'
  pod 'DropDown'
  pod 'SPIndicator'
  pod 'CHIPageControl/Jaloro'
  pod 'OTPFieldView'
  pod 'OneSignal/OneSignal'
  pod 'OneSignal/OneSignalInAppMessages'

  target 'BidCastTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BidCastUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end
end
