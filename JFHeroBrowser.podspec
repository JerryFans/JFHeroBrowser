#
# Be sure to run `pod lib lint JFHeroBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JFHeroBrowser'
  s.version          = '1.4.3'
  s.summary          = 'A simplest & base on protocol & swifty way to browse photo or video with hero animation..'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  *JFHeroBrowser can help you browse your image or video source with hero animation*
  *support any image data like local image, network image , data image, album image ... or use custom protocol to implements your way*
  *support any video data like local file video, network video ,  album video ... or use custom protocol to implements your way*
  *Not include image network cache you should implements the NetworkImageProvider protocol use Kingfisher or SDImageCache*
                       DESC

  s.homepage         = 'https://github.com/JerryFans/JFHeroBrowser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JerryFans' => 'fanjiarong_haohao@163.com' }
  s.source           = { :git => 'https://github.com/JerryFans/JFHeroBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'JFHeroBrowser/Classes/**/*'
  s.swift_version = ['5.0']
  s.resource_bundles = {
     'JFHeroBrowser' => ['JFHeroBrowser/Assets/*.png']
  }
  s.dependency 'JRBaseKit', '~> 1.0.0'
  # s.dependency 'Kingfisher', '~> 6.3.0'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
