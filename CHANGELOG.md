# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
 - Offline queue for uploading visit changes
 - Network Status screen in Settings
 - Warnings when network not available

### Fixed
- Improved visit status synchronization

## [Version 1.0.2, Build 641] - 2019-08-30

### Added
- Version information in About The App
- Version and runtime information in Contact Us
- Path parameter to API events

### Fixed
- Wrong password login attempt now brings up designed dialog

## [Version 1.0.2, Build 640] - 2019-08-29

### Added
- Tapping named place list cells reveals place on map
- Double-tapping named place list cells opens place information screen

### Changed
- Integrates Firebase for analytics and crash reports

### Fixed
- Handles mixed country and territory counts display (Serbia/Kosovo, Denmark/Faroes)
- Improves networking error messages

## [Version 1.0.1, Build 639] - 2019-08-20

### Fixed
- Handles missing locations in ranked user scorecards

## [Version 1.0.1, Build 638] - 2019-08-18

### Added
- Photo tag suggestions from location taken
- Remote notification support

### Changed
- Birthdate display removed from My Profile
- UN visits are checkmarked and have calculation note

### Fixed
- UN Country count now synced with location visit changes
- Map region overlay color updated with visit
- Editing handling improved
- Error messages improved

## [Version 1.0, Build 637] - 2019-08-07

### Added
- Explicit agreement to Terms of Service
- Long-pressing posts and photos brings up menu to hide content, report content, or block user
- Blocked users are hidden from search and display as "Blocked" in rankings
- Blocked posts and photos disappear or are grey placeholders in paged displays

## [Version 1.0, Build 636] - 2019-08-05

### Changed
- Country and location signup/profile fields are now optional

## [Version 1.0, Build 635] - 2019-08-03

### Changed
- Birthday and gender signup/profile fields are now optional

## [Version 1.0, Build 634] - 2019-08-01

### Changed
- Camera permission strings, registration data requests

## [Version 1.0, Build 633] - 2019-07-30

### Added
- Web page headers now display Loading… then page title
- Verify reminder has Resend button

### Changed
- App icon

## [Version 1.0, Build 632] - 2019-07-29

### Added
- Double-tapping a Nearby cell will open More Info directly
- Includes place info data snapshot to deal with network problems during first launch
- Popup reminder to verify account

### Changed
- All place images now loaded from MTP
- Visited and Remaining buttons under maps are now their region colors
- Logout and Delete moved to Settings screen
- Displays message instead of rank 0 when account unverified
- Signup and Edit UI flows improved

### Fixed
- Swiping the Counts pages will not hide the Profile navigation bar
- Sharing the app on an iPad will not crash
- Loading location posts deals with missing authors
- Map marker display state refreshes when visited state toggled in callout 
- Date pickers work correctly in all time zones and with Facebook dates
- Improved result handling of photo uploads

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
