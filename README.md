# [mtp](https://github.com/alexcurylo/mtp)
[![CI](https://github.com/alexcurylo/mtp/workflows/CI/badge.svg)](https://github.com/alexcurylo/mtp/actions?workflow=CI)
[![coverage](https://codecov.io/gh/alexcurylo/mtp/branch/develop/graphs/badge.svg)](https://codecov.io/gh/alexcurylo/mtp)
[![codebeat](https://codebeat.co/badges/321a44b1-ff7b-48fd-b8e2-42a5a8d19568)](https://codebeat.co/projects/github-com-alexcurylo-mtp-develop)
[![issues](https://img.shields.io/github/issues/alexcurylo/mtp.svg)](https://github.com/alexcurylo/mtp/issues)
[![docs](https://alexcurylo.github.io/mtp/badge.svg)](https://alexcurylo.github.io/mtp)
[![chat](https://badges.gitter.im/alexcurylo/mtp.svg)](https://gitter.im/alexcurylo/mtp) 


Table of Contents
-----------------

1. [Purpose](#purpose)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Documentation](#documentation)
5. [Roadmap](#roadmap)
6. [Author](#author)
7. [License](#license)

Purpose
-------

The [Most Traveled People](https://mtp.travel) extreme travel club's [iOS app](https://apps.apple.com/app/id1463245184).

Requirements
------------

- Xcode 11.3 or later
- iOS 11.0 or later

### Tools:

- [Bundler](https://bundler.io/) for Ruby dependency management
- [CocoaPods](https://cocoapods.org/) for code dependency management
- [Codebeat](https://codebeat.co/projects/github-com-alexcurylo-mtp-develop) for automated code review
- [Codecov](https://codecov.io/gh/alexcurylo/mtp) for test coverage statistics
- [Fastlane](https://fastlane.tools) for release management
- [Firebase](https://firebase.google.com/) for analytics and crash reports
- [Github Actions](https://github.com/alexcurylo/mtp/actions?workflow=CI) for CI testing
- [Gitter](https://gitter.im/alexcurylo/mtp?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) for chat
- [Jazzy](https://github.com/realm/jazzy) for generating documentation
- [LicensePlist](https://github.com/mono0926/LicensePlist) for generating acknowledgements
- [Mint](https://github.com/yonaskolb/mint) for tool dependency management
- [SwiftLint](https://github.com/realm/SwiftLint) for opinionated coding style enforcement
- [SwiftMockGeneratorForXcode](https://github.com/seanhenry/SwiftMockGeneratorForXcode) for generating mocks

### Libraries:

- [Alamofire](https://github.com/Alamofire/Alamofire) and [AlamofireNetworkActivityIndicator](https://github.com/Alamofire/AlamofireNetworkActivityIndicator) for HTTP networking
- [Anchorage](https://github.com/Raizlabs/Anchorage) for fluent layout declarations
- [Connectivity](https://github.com/rwbutler/connectivity) for network state manaagement
- [Facebook SDK](https://github.com/facebook/facebook-ios-sdk)  for Facebook support
- [JWTDecode](https://github.com/auth0/JWTDecode.swift) for [JSON Web Token](https://jwt.io) management
- [Karte](https://github.com/kiliankoe/Karte) for launching directions
- [KRProgressHUD](https://github.com/krimpedance/KRProgressHUD) for progress management
- [Moya](https://github.com/Moya/Moya) for network endpoint abstraction
- [Nuke](https://github.com/kean/Nuke) for networked image loading
- [Parchment](https://github.com/rechsteiner/Parchment) for view paging
- [R.swift](https://github.com/mac-cain13/R.swift/) for typed resource identifiers
- [Realm](https://github.com/realm/realm-cocoa) for data management
- [Siren](https://github.com/ArtSabintsev/Siren) for update notifications
- [SwiftEntryKit](https://github.com/huri000/SwiftEntryKit) for notification management
- [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver) for logging

Usage
-----

- Install Ruby + Bundler + Mint as system tools, [Homebrew](https://brew.sh) is a good start
- `bundle install` to install the versioned tools in `Gemfile`
- `mint bootstrap` to install the versioned tools in `Mintfile`
- Build the app with the 'MTP' target.

Documentation
-------------

Read the [docs](http://alexcurylo.github.io/mtp/). Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

Generate for local branch with  `bundle exec jazzy` and open with `open ./docs/index.html`

Roadmap
-------

[Open an issue](https://github.com/alexcurylo/mtp/issues/new) if there's something in particular you'd like to see here.

Author
------

[![web: trollwerks.com](http://img.shields.io/badge/web-www.trollwerks.com-blue.svg)](http://trollwerks.com) 
[![twitter: @trollwerks](http://img.shields.io/badge/twitter-%40trollwerks-blue.svg)](https://twitter.com/trollwerks) 
[![email: alex@trollwerks.com](http://img.shields.io/badge/email-alex%40trollwerks.com-blue.svg)](mailto:alex@trollwerks.com)

License
-------

The [MIT License](http://opensource.org/licenses/MIT). See the [LICENSE.md](LICENSE.md) file for details.

_Copyright &copy;2018-2020 Trollwerks Inc._
