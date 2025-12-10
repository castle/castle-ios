# Releasing

This document describes the tasks to perform for tagging and releasing a new version of the Castle SDK as well as publishing the new release to CocoaPods.

## Prepare for release

 1. Update the version in `Castle.m`, `Castle.podspec` and `README.md`.
 2. Update `GeoZip.xcframwork` and `Highwind.xcframework`
 3. Update `github_file_prefix` in `.jazzy.yaml` to point to the new release tag 
 4. Update documentation by running `scripts/generate_docs.sh` in the project root.
 5. Update the `CHANGELOG.md` for the impending release.
 6. `git commit -am "Prepare for release X.Y.Z."` (where X.Y.Z is the new version).
 7. `git tag -a X.Y.Z -m "Version X.Y.Z"` (where X.Y.Z is the new version).
 8. `git push && git push --tags`.
 9. Create a new version of `Castle.xcframework` by running `fastlane ios xcframework`
 
## Publish to CocoaPods

In order to publish a new version to CocoaPods run the following command from the project root: `pod trunk push Castle.podspec`. Make sure you've executed all the steps in the "Prepare for release" section before publishing.
 
## Create a new release on Github
1. Create a new Github release at https://github.com/castle/castle-ios/releases
     * Add latest version information from `CHANGELOG.md`
     * Add a zip archive including `Castle.xcframework`, `GeoZip.xcframwork` and `Highwind.xcframework`
