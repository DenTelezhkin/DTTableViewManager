Pod::Spec.new do |s|
  s.name     = 'DTTableViewManager'
  s.version  = '4.1.0'
  s.license  = 'MIT'
  s.summary  = 'Protocol-oriented UITableView management, powered by generics and associated types.'
  s.homepage = 'https://github.com/DenHeadless/DTTableViewManager'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin@yandex.ru' }
  s.social_media_url = 'https://twitter.com/DTCoder'
  s.source   = { :git => 'https://github.com/DenHeadless/DTTableViewManager.git', :tag => s.version.to_s }
  s.source_files = 'DTTableViewManager/**/*.{h,swift}'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.platform = :ios,'8.0'
  s.dependency 'DTModelStorage' , '~> 2.0.0'
end
