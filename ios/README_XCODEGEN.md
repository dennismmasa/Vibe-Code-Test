Generate Xcode project (xcodegen)
=================================

This repository includes an `ios/project.yml` for `xcodegen` to produce an Xcode project with iOS and WatchKit targets.

Prerequisites
- Xcode (latest)
- Homebrew (optional, used to install `xcodegen`)
- xcodegen (https://github.com/yonaskolb/XcodeGen)

Quick steps
1. Install xcodegen if needed:

```bash
brew install xcodegen
```

2. Generate the project:

```bash
cd ios
./generate_xcodeproj.sh
```

3. Open the generated project in Xcode:

```bash
open PaceTracker.xcodeproj
```

4. In Xcode: select the paired iPhone+Watch target, set your Team in Signing & Capabilities, then build & run on the device pair.

If you prefer I can attempt to commit the generated `.xcodeproj` into this repo for you, but generated Xcode project files are large and may need signing adjustments specific to your Apple Developer account.
