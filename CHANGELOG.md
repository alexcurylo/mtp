# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Welcome to the MTP iOS app! I'm Alex, the lead mobile app developer for MTP.

Please delete any previous builds from your device and reinstall this version - the way place images are stored has changed so the app needs to reload all its place data for those to show up.

The best way to let us know about any problems or suggestions is in the TestFlight app you use to install the MTP app - a little down from the "Install" button you'll see a "Send Beta Feedback" button. That'll let you send us an email with information about your device attached, which will help us reproduce any problems you describe.

### Added
- Double-tapping a Nearby cell will open More Info directly
- Includes place info data snapshot to deal with network problems during first launch

### Changed
- All place images now loaded from MTP
- Visited and Remaining buttons under maps are now their region colors
- Logout and Delete moved to Settings screen

### Fixed
- Swiping the Counts pages will not hide the Profile navigation bar
- Sharing the app on an iPad will not crash
- Loading location posts deals with missing authors
- Map display refreshes when visit toggled in callout 

## [Version 1.0, Build 631] - 2019-07-21

### Added
- Your displayed rank in a list is highlighted when visits have changed and the rank may not have been updated (this happens once an hour on the website currently)

### Changed
- Nearby screen now calculates distances from map center not your position
- WHS images now loaded from MTP not UNESCO when possible
- Marking or unmarking visits now enforces immediate synchronization with website

### Fixed
- Visited counts display correctly everywhere immediately, both in app and on website
- Ranking list data is marked as out of date after an hour

## [Version 1.0, Build 630] - 2019-07-14

### Added
- Tapping photos now expands to full screen lightbox
- More Info pages now laid out with information links
- Add Photo pages now have camera option
- Count pages now have header totals, arrows now blue, rendering improved
- Delayed checkin notifications now include visit time

### Fixed
- Map markers now always appear
- WHS children visits and list display now handled correctly
- Inactive application state now triggers background checkin notification
- Map nav buttons now rendered non-templated to catch all taps
- Improved network failure diagnostics

## [Version 1.0, Build 629]

- CHANGELOG.md created

[Unreleased]: https://github.com/alexcurylo/mtp/compare/master...HEAD
