Pod::Spec.new do |spec|
  spec.name = 'MongoSwiftMobile'
  spec.authors = { 'Jason Flax' => 'jason.flax@mongodb.com' }
  spec.license = 'Apache 2'
  spec.homepage = 'https://github.com/mongodb/stitch-ios-sdk'
  spec.source = {
    :git => "https://github.com/jsflax/stitch-ios-sdk.git",
    :tag => "4.0.0-beta-3"
  }
  spec.platform = :ios, "11.0"
  spec.summary = 'Blah'
  spec.version = '4.0.0-beta-3'
  spec.source_files = 'vendor/Sources/MongoSwift/**/*.swift'
end