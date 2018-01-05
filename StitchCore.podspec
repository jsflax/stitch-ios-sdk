Pod::Spec.new do |s|
  s.name         = "StitchCore"
  s.version      = "2.0.2"
  s.authors	 = "MongoDB"
  s.homepage     = "https://mongodb.com/cloud/stitch"
  s.summary      = "An SDK to use MongoDB's Stitch Core features."
  s.license      = {
    :type => "Apache 2",
    :file => "./LICENSE"
  }
  s.platform     = :ios, "9.0"
  s.requires_arc = true
  s.source       = { 
    :git => "https://github.com/jsflax/stitch-ios-sdk.git",
    #:tag => "#{s.version}"
    :tag => 'STITCH-1036'
  }

  s.source_files = Dir["StitchCore/StitchCore/**/*.swift"]
  s.frameworks = 'Foundation'
  s.requires_arc = true

  s.preserve_paths = './StitchCore/PromiseKit.framework'
  s.vendored_frameworks = './StitchCore/PromiseKit.framework'
#  s.dependency "PromiseKit", :tag => 'https://github.com/mxcl/PromiseKit/releases/tag/5.0.3'
  s.dependency "StitchLogger", "~> 2.0.0"
  s.dependency "ExtendedJson", "~> 2.0.1"
end
