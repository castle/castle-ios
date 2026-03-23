# Releasing

This document describes the tasks to perform for tagging and releasing a new version of the Castle SDK.

## Prepare for release
 1. `git checkout -b "release/x.x.x"
 2. Update the version in `README.md`.
 3. Update the `CHANGELOG.md` for the impending release.
 4. `git commit -am "Prepare for release x.x.x"`
 5. `git tag -a x.x.x -m "Version x.x.x"`
 6. `git push && git push --tags`.

## Create a new release on Github
1. Create a new Github release at https://github.com/castle/castle-ios/releases
     * Add latest version information from `CHANGELOG.md`
     * Add zip archive including `Castle.xcframework` from private repository.

