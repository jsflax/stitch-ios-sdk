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

  hh = Dir['StitchCore/PromiseKit/Sources/*.h'] - Dir['StitchCore/PromiseKit/Sources/*+Private.h']

  cc = Dir['StitchCore/PromiseKit/Sources/*.swift'] - ['StitchCore/PromiseKit/Sources/SwiftPM.swift']
  cc << 'StitchCore/PromiseKit/Sources/{after,AnyPromise,GlobalState,dispatch_promise,hang,join,PMKPromise,when}.m'
  cc += hh

  s.source_files = cc + Dir["StitchCore/StitchCore/**/*.swift"]
  s.public_header_files = hh
  s.preserve_paths = 'StitchCore/PromiseKit/Sources/AnyPromise+Private.h', 'StitchCore/PromiseKit/Sources/PMKCallVariadicBlock.m', 'StitchCore/PromiseKit/Sources/NSMethodSignatureForBlock.m'
  s.frameworks = 'Foundation'
  s.requires_arc = true

  #s.preserve_paths = "StitchCore/Frameworks/PromiseKit.framework"
  s.vendored_frameworks = "StitchCore/Frameworks/PromiseKit.framework"
  s.dependency "PromiseKit", "~> 5.0.0"
  s.dependency "StitchLogger", "~> 2.0.0"
  s.dependency "ExtendedJson", "~> 2.0.1"
end
