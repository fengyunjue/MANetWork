#
# Be sure to run `pod lib lint MANetWork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MANetWork'
    s.version          = '0.1.7'
    s.summary          = 'A short description of MANetWork.'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC

    s.homepage         = 'https://github.com/fengyunjue/MANetWork'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'ma772528138@qq.com' => 'ma772528138@qq.com' }
    #s.source           = { :git => '.', :tag => s.version.to_s }
    s.source           = { :git => 'https://github.com/fengyunjue/MANetWork.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '9.0'

    s.pod_target_xcconfig = {
        'SWIFT_VERSION' => '4.1'
    }

    s.source_files = 'MANetWork/Routerable.swift', 'MANetWork/Alamofire+Custom.swift', 'MANetWork/HttpManager.swift'
    #s.public_header_files = 'MANetWork/**/*'

    s.subspec 'Rx' do |ss|
        ss.source_files = 'MANetWork/RxHttpManager.swift'

        ss.dependency 'SVProgressHUD'
        ss.dependency 'RxSwift'
    end

    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'Alamofire'
    s.dependency 'SwiftyJSON'
end
