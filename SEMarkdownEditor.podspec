Pod::Spec.new do |s|

  s.name         = "SEMarkdownEditor"
  s.version      = "0.1.0"
  s.summary      = "Text transformation functions for implementing a markdown toolbar in an iOS app."

  s.homepage     = "https://github.com/bnickel/SEMarkdownEditor"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Brian Nickel" => "bnickel@stackexchange.com" }
  
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/bnickel/SEMarkdownEditor.git", :tag => "v#{s.version}" }


  s.source_files = "SEMarkdownEditor/Core"
  s.ios.source_files = "SEMarkdownEditor/UIKit"

  s.public_header_files = "SEMarkdownEditor/Core/**/*.h"
  s.ios.public_header_files = "SEMarkdownEditor/UIKit/**/*.h"

  s.frameworks = "Foundation"
  s.ios.frameworks = "UIKit"

  s.requires_arc = true

end
