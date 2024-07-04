#
# Be sure to run `pod lib lint XZRefreshing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZRefreshing'
  s.version          = '2.0.0'
  s.summary          = '迄今为止 iOS 最流畅的下拉刷新、上拉加载组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      XZRefreshing 已更名为 XZRefresh 了，请直接使用 XZRefresh 代替。
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZRefresh'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'developer@xezun.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZRefresh.git', :branch => "main" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }

  s.deprecated = true  
  s.deprecated_in_favor_of = "rename to XZRefresh"
  
  s.dependency 'XZRefresh'
  
end

