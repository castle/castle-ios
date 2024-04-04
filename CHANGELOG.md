# Changelog

## 3.0.10 (2024-04-04)
- [#110](https://github.com/castle/castle-ios/pull/110) Include Privacy manifest, update internal frameworks

## 3.0.9 (2024-03-15)
- [#106](https://github.com/castle/castle-ios/pull/106) Update event queue storage path, add migration code and update tests
- Fix: [#107](https://github.com/castle/castle-ios/pull/107) Update framworks to versions that doesn't include BCSymbolMaps

## 3.0.8 (2024-02-14)
- Improvement: [#102](https://github.com/castle/castle-ios/pull/102) Add support for providing IDFA.

## 3.0.7 (2022-08-09)
- Fixes a bug that could result in the app crashing when the location accuracy is less than 1 meter.

## 3.0.6 (2022-06-29)
- Internal enhancements and stability improvements.

## 3.0.5 (2022-05-10)
- Fix: [#94](https://github.com/castle/castle-ios/pull/94) Add check to determine if the SDK has been configured in resetConfiguration.

## 3.0.4 (2022-04-29)
- Improvement: [#89](https://github.com/castle/castle-ios/pull/89) Decrease batch size to 20.
- Fix: [#90](https://github.com/castle/castle-ios/pull/90) Potential crash when UUID is nil.
- Fix: [#91](https://github.com/castle/castle-ios/pull/91) Remove SwiftSources from exclude in Package.swift.

## 3.0.3 (2022-04-06)
- Improvement: [#86](https://github.com/castle/castle-ios/pull/86) Null/empty request tokens. More strict checks that the SDK is configured before use.
- Internal enhancements and stability improvements.

## 3.0.2 (2022-03-29)
- Internal enhancements and stability improvements.

## 3.0.1 (2022-03-15)
- Fix: [#83](https://github.com/castle/castle-ios/pull/83) Clear event queue if there is an error when reading from storage.

## 3.0.0 (2022-03-15)
- Add support for enhanced user activity monitoring.
	- Introduced custom(name:) method
	- Introduced custom(name:properties:) method
	- Introduced screen(name:) method
	- Introduced userJwt() method
- Remove deprecated methods.
	- Removed identify()
	- Removed userId()
	- Removed secure()
	- Removed secureModeEnabled()
	- Removed userSignature
	- Removed track()
	- Removed useCloudflareApp()
	- Removed field CastleClientIdHeaderName = "X-Castle-Client-Id";

## 2.1.8 (2022-03-12)
- Updated internal library because of an issue with the vendored framework included in the 2.1.7 release.

## 2.1.7 (2022-02-25)
- Fixes a rare bug that resulted in incorrectly encoded request tokens.

## 2.1.6 (2022-02-09)
- Fixes a rare bug where the request token would occasionally get encoded incorrectly and consequently rejected by the API.

## 2.1.5 (2021-12-09)
- Improved device fingerprinting.

## 2.1.4 (2021-11-16)
- Fix: [#73](https://github.com/castle/castle-ios/pull/73) Add dependencies Highwind and GeoZip to Package.swift.

## 2.1.3 (2021-11-15)
- Fix: [#71](https://github.com/castle/castle-ios/pull/71) Remove COCOAPODS macro check from Castle.h.

## 2.1.2 (2021-09-14)
- Device parameter collection improvements.

## 2.1.1 (2021-06-08)
- Fix: [#64](https://github.com/castle/castle-ios/pull/64) Remove duplicate bcsymbolfiles, update import in umbrella header.
- Fix: [#63](https://github.com/castle/castle-ios/pull/63) Expose CastleRequestTokenHeaderName const.

## 2.1.0 (2021-06-03)
- Fix: [#60](https://github.com/castle/castle-ios/pull/60) Failing tests when automated screen tracking is off by default
- Fix: [#59](https://github.com/castle/castle-ios/pull/59) Potential crash in fingerpringting when called on another thread.

## 2.0.1 (2021-05-18)
- Fix: [#57](https://github.com/castle/castle-ios/pull/57) Add NSNull null fallback in CASContext.JSONPayload.

## 2.0.0 (2021-04-20)
- Feature: [#52](https://github.com/castle/castle-ios/pull/52) Extended and improved device parameter collection.

## 1.0.10 (2021-03-19)
- Fix: [#50](https://github.com/castle/castle-ios/pull/50) Carthage build.
- Fix: [#48](https://github.com/castle/castle-ios/pull/48) Link to correct docs.

## 1.0.9 (2021-03-09)

- Fix: [#47](https://github.com/castle/castle-ios/pull/47) NSKeyedUnarchiver deprecated tests.
- Fix: [#46](https://github.com/castle/castle-ios/pull/46) Use allowlist.

## 1.0.8 (2021-03-05)

- Fix: [#45](https://github.com/castle/castle-ios/pull/45) Use [NSNull null] if clientId is nil.

## 1.0.7 (2021-01-21)

- Improvement: [#43](https://github.com/castle/castle-ios/pull/43) Proper handling of nullable properties/functions.

## 1.0.6 (2021-01-05)

- Improvement: [#42](https://github.com/castle/castle-ios/pull/42) Include model version in user agent string.
- Fix: [#41](https://github.com/castle/castle-ios/pull/41) Upgrade example project for Xcode 12.

## 1.0.5 (2020-10-05)

- Fix: [#40](https://github.com/castle/castle-ios/pull/40) Upgrade example project for Xcode 12.
- Improvement: [#39](https://github.com/castle/castle-ios/pull/39) Add ability to enable Cloudflare app proxy usage.

## 1.0.4 (2020-03-28)

- Fix: [#37](https://github.com/castle/castle-ios/pull/37) Fix Carthage build.

## 1.0.3 (2020-03-03)

- [#34](https://github.com/castle/castle-ios/pull/34) Remove custom event tracking.
- [#35](https://github.com/castle/castle-ios/pull/35) Remove ability to add custom properties on events.

## 1.0.2 (2020-01-13)

- Fix: [#33](https://github.com/castle/castle-ios/pull/33) Reduce the number of screen events produced by the automatic screen tracking

## 1.0.1 (2019-03-12)

- Fix: [#32](https://github.com/castle/castle-ios/pull/32) User agent should include device model not device name

## 1.0.0 (2019-02-19)

- Improvement: [#30](https://github.com/castle/castle-ios/pull/30) Podspec improvements and fixes
- Improvement: [#29](https://github.com/castle/castle-ios/pull/29) User Agent validation test
- Improvement: [#28](https://github.com/castle/castle-ios/pull/28) Set custom timeout for all API Requests
- Fix: [#27](https://github.com/castle/castle-ios/pull/27) Remove device name from event payload
- Fix: [#26](https://github.com/castle/castle-ios/pull/26) Remove references to deprecated NSKeyedArchiver API.
- Improvement: [#25](https://github.com/castle/castle-ios/pull/25) Use a custom User Agent for all requests to the Castle API
- Fix: [#24](https://github.com/castle/castle-ios/pull/24) Exclude event storage from iCloud backup
- Fix: [#23](https://github.com/castle/castle-ios/pull/23) Fix timestamp format
- Improvement: [#22](https://github.com/castle/castle-ios/pull/22) Remove vendor and example from code coverage report
- Fix: [#21](https://github.com/castle/castle-ios/pull/21) Fix userid and signature event persistence.
- Fix: [#20](https://github.com/castle/castle-ios/pull/20) Set locale for timestamp date formatter to en-US
- Improvement: [#19](https://github.com/castle/castle-ios/pull/19) Add release documentation
- Feature: [#18](https://github.com/castle/castle-ios/pull/18) Add support for secure mode
- Feature: [#17](https://github.com/castle/castle-ios/pull/17) Documentation for public API
- Fix: [#16](https://github.com/castle/castle-ios/pull/16) Enforce max event queue limit
- Improvement: [#15](https://github.com/castle/castle-ios/pull/15) Migrate to Circle CI
- Improvement: More comprehensive tests (~90% code coverage)
