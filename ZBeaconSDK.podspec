#
# Be sure to run `pod lib lint ZBeaconSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZBeaconSDK'
  s.version          = '1.0.202011201013'
  s.summary          = 'ZBeacon SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ZBeacon SDK
                       DESC

  s.homepage         = 'https://github.com/VNG-Zalo/ZBeaconSDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'minhtoantm' => 'minhtoan3101@gmail.com' }
  s.source           = { :git => 'https://github.com/VNG-Zalo/ZBeaconSDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.subspec 'Main' do |cs|
    cs.ios.vendored_frameworks = 'ZBeaconSDK/Frameworks/ZBeaconSDK.framework'
  end

  s.default_subspecs = 'Main'

end
