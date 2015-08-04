## [1.3.3]() (2014-08-04)

#### Feature
* Add API for app to input App's AD position to avoid CrystalExpress insert beside App's AD

#### Fixed
* CETableViewADHelper - (NSIndexPath *)positionToIndexPath:(int)position calculate wrong bug
* Add flag in CETableViewADHelper loadAd to control load CrystalExpress AD


## [1.3.2]() (2014-08-03)

#### Feature
* Replace WiFi marquee with WiFi hint label animation and tag
* Optimize card format cover UI

#### Fixed
* Change Splash Ad cancel auto dimiss timer to viewWillDisappear
* Stream AD does not set active placement in CEStreamADHelper
* Allow user interaction while AD view animating
* Fix Stream AD insertion algorithm


## [1.3.1]() (2015-07-30)

#### Feature
* Support some bulit-in Splash AD present/dismiss animations
* Support customized Splash AD present/dismiss animation

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

