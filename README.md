# [mtp](https://github.com/alexcurylo/mtp)
[![Travis](https://travis-ci.org/alexcurylo/mtp.svg?branch=develop)](https://travis-ci.org/alexcurylo/mtp)
[![CI](https://github.com/alexcurylo/mtp/workflows/CI/badge.svg)](https://github.com/alexcurylo/mtp/actions?workflow=CI)
[![Issues](https://img.shields.io/github/issues/alexcurylo/mtp.svg)](https://github.com/alexcurylo/mtp/issues)
[![Xcode](https://img.shields.io/badge/Xcode-11.1-blue.svg)](https://developer.apple.com/xcode)
[![Swift](https://img.shields.io/badge/Swift-5.1-orange.svg)](https://swift.org)
[![MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![codebeat](https://codebeat.co/badges/321a44b1-ff7b-48fd-b8e2-42a5a8d19568)](https://codebeat.co/projects/github-com-alexcurylo-mtp-develop)
[![codecov.io](https://codecov.io/gh/alexcurylo/mtp/branch/develop/graphs/badge.svg)](https://codecov.io/gh/alexcurylo/mtp)
[![coverage](https://coveralls.io/repos/github/alexcurylo/mtp/badge.svg?branch=develop)](https://coveralls.io/github/alexcurylo/mtp?branch=develop)
[![docs](https://alexcurylo.github.io/mtp/badge.svg)](https://alexcurylo.github.io/mtp)
[![Join the chat at https://gitter.im/alexcurylo/mtp](https://badges.gitter.im/alexcurylo/mtp.svg)](https://gitter.im/alexcurylo/mtp?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) 


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

- Xcode 11.1 or later
- iOS 11.0 or later

### Tools:

- [Bundler](https://bundler.io/) for Ruby dependency management
- [CocoaPods](https://cocoapods.org/) for code dependency management
- [Codebeat](https://codebeat.co/projects/github-com-alexcurylo-mtp-develop) for automated code review
- [Coveralls](https://coveralls.io/github/alexcurylo/mtp?branch=develop) for test coverage statistics
- [Fastlane](https://fastlane.tools) for release management
- [Firebase](https://firebase.google.com/) for analytics and crash reports
- [Github Actions](https://github.com/alexcurylo/mtp/actions?workflow=Test) for CI testing
- [Gitter](https://gitter.im/alexcurylo/mtp?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) for chat
- [Jazzy](https://github.com/realm/jazzy) for generating documentation
- [Mint](https://github.com/yonaskolb/mint) for tool dependency management
- [Slather](https://github.com/SlatherOrg/slather) for test coverage reports
- [SwiftLint](https://github.com/realm/SwiftLint) for opinionated coding style enforcement
- [SwiftMockGeneratorForXcode](https://github.com/seanhenry/SwiftMockGeneratorForXcode) for generating mocks
- [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver) for logging
- [Travis-CI](https://travis-ci.org/alexcurylo/mtp) for CI testing

### Libraries:

- [Alamofire](https://github.com/Alamofire/Alamofire) and [AlamofireNetworkActivityIndicator](https://github.com/Alamofire/AlamofireNetworkActivityIndicator) for HTTP networking
- [Anchorage](https://github.com/Raizlabs/Anchorage) for fluent layout declarations
- [Facebook SDK in Swift](https://github.com/facebook/facebook-sdk-swift)  for Facebook support
- [JWTDecode](https://github.com/auth0/JWTDecode.swift) for [JSON Web Token](https://jwt.io) management
- [KRProgressHUD](https://github.com/krimpedance/KRProgressHUD) for progress management
- [Moya](https://github.com/Moya/Moya) for network endpoint abstraction
- [Nuke](https://github.com/kean/Nuke) for networked image loading
- [Parchment](https://github.com/rechsteiner/Parchment) for view paging
- [R.swift](https://github.com/mac-cain13/R.swift/) for typed resource identifiers
- [Realm](https://github.com/realm/realm-cocoa) for data management
- [SwiftEntryKit](https://github.com/huri000/SwiftEntryKit) for notification management

Usage
-----

Build the app with the 'MTP' target.

Documentation
-------------

Read the [docs](http://alexcurylo.github.io/mtp/). Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

Generate for local branch with  `bundle exec jazzy` and open with `open ./docs/index.html`

Roadmap
-------

Feel free to [open an issue](https://github.com/alexcurylo/mtp/issues/new) if there's something in particular you'd like to see here.

Author
------

[![web: trollwerks.com](http://img.shields.io/badge/web-www.trollwerks.com-blue.svg)](http://trollwerks.com) 
[![twitter: @trollwerks](http://img.shields.io/badge/twitter-%40trollwerks-blue.svg)](https://twitter.com/trollwerks) 
[![email: alex@trollwerks.com](http://img.shields.io/badge/email-alex%40trollwerks.com-blue.svg)](mailto:alex@trollwerks.com)

License
-------

The [MIT License](http://opensource.org/licenses/MIT). See the [LICENSE.md](LICENSE.md) file for details.

_Copyright &copy;2018-present Trollwerks Inc._
