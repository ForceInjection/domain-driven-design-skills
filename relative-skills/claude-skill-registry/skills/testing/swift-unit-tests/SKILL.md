---
name: swift-unit-tests
description: How to run swift unit tests
---

1. List available simulators with `xcrun simctl list devices available`
2. If one is booted already, use that. Prefer iPhone xx Pros, the latest ones
3. Run the unit tests with `xcodebuild test -project YourApp.xcodeproj -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`. The app is usually in the root of the directory. The simulator is the one from step 2. The scheme has to be found out
