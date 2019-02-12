# Releasing

This document describes the tasks to perform for tagging and releasing a new version of the Castle SDK as well as publishing the new release to CocoaPods.

## Prepare for release

 1. Update the version in `Castle.m`, `Castle.podspec` and `README.md`.
 2. Update documentation by running `jazzy` in the project root.
 3. Update the `CHANGELOG.md` for the impending release.
 4. `git commit -am "Prepare for release X.Y.Z."` (where X.Y.Z is the new version).
 5. `git tag -a X.Y.Z -m "Version X.Y.Z"` (where X.Y.Z is the new version).
 6. `git push && git push --tags`.
 
## Publish to CocoaPods

In order to publish a new version to CocoaPods run the following command from the project root: `pod trunk push Castle.podspec`. Make sure you've executed all the steps in the "Prepare for release" section before publishing.
 
## Create a new release on Github
1. Create a new Github release at https://github.com/castle/castle-ios/releases
     * Add latest version information from `CHANGELOG.md`