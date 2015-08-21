#!/usr/bin/env sh
# Builds the PhoneGap Demo with Swrve's push-ready profile
set -e

PROFILE_NAME="iOS Test App Production Ad Hoc"

function failure {
  echo ""
  echo "Problem running command: $1"
  exit 1
}

echo "Exporting and signing $APPNAME"
(xcodebuild -project Hello\ World.xcodeproj/ -scheme "Hello World" -config "Ad Hoc" -archivePath HelloWorld_archive archive)
BUILD=$?
if [ "$BUILD" -ne 0 ]; then
  failure "Problem exporting $APPNAME $BUILD"
fi

(rm -f HelloWorld.ipa; xcodebuild -archivePath "HelloWorld_archive.xcarchive" -exportPath "HelloWorld.ipa" -exportFormat ipa -exportArchive -exportProvisioningProfile "${PROFILE_NAME}")
BUILD=$?
if [ "$BUILD" -ne 0 ]; then
  failure "Problem signing $APPNAME $BUILD"
fi

echo "HelloWorld.ipa succesfully created"

