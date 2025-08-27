fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### release

```sh
[bundle exec] fastlane release
```

Publish to Play Store, App Store, GitHub

### promote

```sh
[bundle exec] fastlane promote
```

Promote on Play Store, App Store, GitHub

----


## Android

### android alpha

```sh
[bundle exec] fastlane android alpha
```

Build and upload to Play Store Alpha track

### android alphapro

```sh
[bundle exec] fastlane android alphapro
```

Promote Play Store Alpha to Prod

### android playstore

```sh
[bundle exec] fastlane android playstore
```

Build and release to Play Store

### android github

```sh
[bundle exec] fastlane android github
```

Build an APK and release to GitHub

----


## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Build and upload to TestFlight

### ios testpro

```sh
[bundle exec] fastlane ios testpro
```

Promote TestFlight to Prod

### ios applestore

```sh
[bundle exec] fastlane ios applestore
```

Build and release to App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
