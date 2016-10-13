SHELL := /bin/bash
# Install Tasks

install-iOS:
	xcrun instruments -w "iPhone 6s (10.0)" || true

install-tvOS:
	xcrun instruments -w "Apple TV 1080p (10.0)" || true

install-carthage:
	brew remove carthage --force || true
	brew install carthage

install-cocoapods:
	gem install cocoapods --pre --no-rdoc --no-ri --no-document --quiet

# Run Tasks

test-iOS:
	set -o pipefail && xcodebuild -project DTTableViewManager.xcodeproj -scheme DTTableViewManager-iOS -destination "name=iPhone 6s" -enableCodeCoverage YES test -configuration "Release" | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-tvOS:
	set -o pipefail && xcodebuild -project DTTableViewManager.xcodeproj -scheme DTTableViewManager-tvOS -destination "name=Apple TV 1080p" -enableCodeCoverage YES test -configuration "Release" | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-carthage:
	carthage build --no-skip-current --verbose --platform iOS
	ls Carthage/build/iOS/DTTableViewManager.framework

test-cocoapods:
	pod repo update && pod lib lint --allow-warnings --verbose
