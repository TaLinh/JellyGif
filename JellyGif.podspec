Pod::Spec.new do |s|
  s.name         = 'JellyGif'
  s.version      = '1.0.2'
  s.summary      = 'A framework used to animate GIF'
  s.description  = 'A lightweight, performant, and memory efficient framework used to animate GIF'
  s.homepage     = 'https://github.com/TaLinh'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Linh Ta' => 'linhtadev@gmail.com' }
  #s.source       = { :path => '../JellyGif' }
  s.source       = { :git => 'https://github.com/TaLinh/JellyGif.git', :tag => '1.0.2' }
  s.source_files  = 'JellyGif/**/*.{h,m,swift}'

  s.author             = { 'Linh Ta' => 'linhtadev@gmail.com' }
  s.social_media_url   = 'https://linhta.dev'
  s.platform  = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.ios.framework  = 'UIKit'
end