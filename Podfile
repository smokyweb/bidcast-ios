# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BidCast' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # ──────────────────────────────────────────────────────────────────
  # Existing UI + utility pods (kept as-is)
  # ──────────────────────────────────────────────────────────────────
  pod 'Kingfisher'
  pod 'SVProgressHUD'
  pod 'IQKeyboardManagerSwift'
  pod 'FittedSheets'
  pod 'Toast-Swift'
  pod 'DropDown'
  pod 'SideMenu'
  pod 'CropViewController'
  pod 'FSCalendar'
  pod 'SPIndicator'
  pod 'CHIPageControl/Jaloro'
  pod 'OTPFieldView'

  # ──────────────────────────────────────────────────────────────────
  # iOS parity phase 1b (2026-04-22): foundation pods for Android parity.
  # DO NOT run `pod install` locally \u2014 Codemagic handles pod install on
  # every build. Locally, `pod install` will fail because CocoaPods is not
  # installed on the build machine.
  #
  # Version pinning rationale:
  #   - Socket.IO-Client-Swift 16.1.x       matches Android's socket.io 2.x client
  #   - AgoraRtcEngine_iOS 4.3.x            lite-sdk equivalent of Android's 4.6.1
  #                                         (use 4.6.x later when we port the real
  #                                         Android SocketManager/AgoraManager; 4.3
  #                                         is a safe starting floor)
  #   - Stripe 23.30.x / StripePaymentSheet matches the Bluestone-standard Stripe
  #                                         stack we are already using elsewhere
  #   - Firebase modules unpinned           takes whatever the live pods repo
  #                                         ships \u2014 Codemagic builds pin via
  #                                         Podfile.lock on first pod install
  # ──────────────────────────────────────────────────────────────────

  # Live-stream infrastructure
  pod 'Socket.IO-Client-Swift', '~> 16.1.0'
  pod 'AgoraRtcEngine_iOS', '~> 4.3.0'

  # Payments (Stripe SDK)
  pod 'Stripe', '~> 23.30.0'
  pod 'StripePaymentSheet', '~> 23.30.0'

  # Firebase — FCM (push), Analytics, Crashlytics in later phase.
  # Database module intentionally held back until we confirm whether the
  # Bidcast backend actually uses Realtime Database for in-stream products
  # / 1:1 chat, or only for chat. Android uses Firebase/Database for both.
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  # pod 'Firebase/Database'        # TODO(phase 2): enable when chat port lands
  # pod 'Firebase/Crashlytics'     # TODO(phase 7): enable when crash reporting lands

  # Utilities Android already uses (keep parity on helper surface)
  pod 'Alamofire', '~> 5.9.0'
  pod 'SwiftyJSON', '~> 5.0'

  # OneSignal removed 2026-04-22: recon confirmed OneSignal is not initialized
  # anywhere in AppDelegate and only appears as a commented-out import in
  # SignInViewController. Android uses Firebase Cloud Messaging (FCM), so we
  # switch iOS to FCM too (above) for payload-format parity.
  # pod 'OneSignal/OneSignal'
  # pod 'OneSignal/OneSignalInAppMessages'

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
        # Disable code signing on all Pods targets (fixes archive failing with
        # "No iOS Distribution signing certificate matching team ID" errors).
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      end
    end
  end
end
