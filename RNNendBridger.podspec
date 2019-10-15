require "json"

Pod::Spec.new do |s|
  # NPM package specification
  package = JSON.parse(File.read(File.join(File.dirname(__FILE__), "package.json")))

  s.name         = "RNNendBridger"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = "https://github.com/fan-ADN/nendSDK-react-native"
  s.license      = "MIT"
  s.author       = { package["author"]["name"] => package["author"]["email"] }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/fan-ADN/nendSDK-react-native", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift}"

  s.dependency "React"
  s.dependency "NendSDK_iOS"
  s.static_framework = true
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

end
