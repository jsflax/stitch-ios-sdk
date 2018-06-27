mkdir -p Sources
# download MongoSwift
if [ ! -d Sources/MongoSwift ]; then
  log_i "downloading MongoSwift"
  curl -# -L https://api.github.com/repos/mongodb/mongo-swift-driver/tarball > mongo-swift.tgz
  mkdir mongo-swift
  # extract mongo-swift
  tar -xzf mongo-swift.tgz -C mongo-swift --strip-components 1
  # copy it to vendored Sources dir
  cp -r mongo-swift/Sources/MongoSwift Sources/MongoSwift
  # remove artifacts
  rm -rf mongo-swift mongo-swift.tgz
else
  log_w "skipping downloading MongoSwift"
fi