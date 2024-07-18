Pod::Spec.new do |s|
  s.name             = 'GKScrollView'
  s.version          = '1.0.0'
  s.summary          = '上下滑动切换页面'
  s.homepage         = 'https://github.com/QuintGao-Swift/GKScrollView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'QuintGao' => '1094887059@qq.com' }
  s.source           = { :git => 'https://github.com/QuintGao-Swift/GKScrollView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/QuintGao'
  s.ios.deployment_target = '10.0'
  s.source_files = 'GKScrollView/*.{swift}'
  s.swift_version = '5.0'
end
