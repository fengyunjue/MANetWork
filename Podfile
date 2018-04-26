source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

target 'SwiftHTTPManager' do

    pod 'MANetWork', :path => '.'
    #pod 'Alamofire'
    #pod 'SwiftyJSON'
    #pod 'SVProgressHUD'
    #pod 'RxSwift', :inhibit_warnings => true
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.1'
        end
    end
end

