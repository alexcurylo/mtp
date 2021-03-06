fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios release
```
fastlane ios release
```
Push a new release build to the App Store
### ios screenshots
```
fastlane ios screenshots
```
Generate new localized screenshots
### ios give_simulators_permissions
```
fastlane ios give_simulators_permissions
```
Prepare simulators for screenshots
### ios bump
```
fastlane ios bump
```
Bump patch version number
### ios bumpMinor
```
fastlane ios bumpMinor
```
Bump minor version number
### ios bumpMajor
```
fastlane ios bumpMajor
```
Bump major version number

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
