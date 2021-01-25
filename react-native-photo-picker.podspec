require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-photo-picker"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = "react-native-photo-picker"
  s.homepage     = "https://github.com/makedirectory/react-native-photo-picker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-photo-picker.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
end
