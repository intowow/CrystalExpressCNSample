## [1.3.1]() (2015-07-30)

#### Fixed
* Change CETableViewADHelper API from `refreshAd` to `cleanAds` to clearify the meaning
* Fix CEStreamADHelper strong delegate reference
* Fix CESplashAD does not release pointer while viewcontroller dismissed

---
## [1.3.0]() (2015-07-29)

#### Feature
* Support multiple frequency cap
* Support geo targeting AD serving
* Support multiple 3rd party impression tracking
* Support QR code change current geographic location
* New Splash/Stream integration API

#### Fixed
* Wrong frequency cap time calculate
* Does not check glocal capped in ADMatcher
* Only CPH time slot check in Prefetcher

