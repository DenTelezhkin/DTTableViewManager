SHELL := /bin/bash
# Install Tasks

install-iOS:
	true

install-tvOS:
	true

install-carthage:
	brew remove carthage --force || true
	brew install carthage

install-cocoapods:
	true

# install-oss-osx:
# 	curl -sL https://gist.githubusercontent.com/kylef/5c0475ff02b7c7671d2a/raw/b07054552689910f79b3496221f7421a811f9f70/swiftenv-install.sh | bash

# Run Tasks

test-iOS:
	set -o pipefail && xcodebuild -project DTTableViewManager.xcodeproj -scheme DTTableViewManager-iOS -destination "name=iPhone 6s" -enableCodeCoverage YES test | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-tvOS:
	set -o pipefail && xcodebuild -project DTTableViewManager.xcodeproj -scheme DTTableViewManager-tvOS -destination "name=Apple TV 1080p" -enableCodeCoverage YES test | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-carthage:
	carthage build --no-skip-current --verbose --platform iOS
	ls Carthage/build/iOS/DTTableViewManager.framework

test-cocoapods:
	pod lib lint --allow-warnings --verbose

# test-oss-osx:
# 	git clone https://github.com/apple/swift-package-manager
# 	cd swift-package-manager && git checkout 6b8ec91
# 	. ~/.swiftenv/init && \
# 		swift-package-manager/Utilities/bootstrap && \
# 		$(PWD)/swift-package-manager/.build/debug/swift-build && \
# 		$(PWD)/swift-package-manager/.build/debug/swift-test
