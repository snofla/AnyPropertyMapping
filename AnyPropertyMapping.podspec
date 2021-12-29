Pod::Spec.new do |s|
  s.name             = 'AnyPropertyMapping'
  s.version          = '1.1.1'
  s.summary          = 'Maps properties of two classes using keypaths'
  s.homepage         = 'https://github.com/snofla/AnyPropertyMapping'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Alfons Hoogervorst' => 'alfons.hoogervorst@gmail.com' }
  s.source           = { :git => 'https://github.com/snofla/AnyPropertyMapping.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/AnyPropertyMapping/**/*'
end
