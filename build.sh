#!/bin/bash

#  Automatic build script for simple-share
#  for iOS and iOSSimulator
#
#  Created by Felix Schulze on 01.06.12.
#  Copyright 2012 Felix Schulze. All rights reserved.
###########################################################################
#
SDKVERSION="5.1"
#
###########################################################################
#
# Don't change anything here
DEVICESDK="iphoneos${SDKVERSION}"
SIMSDK="iphonesimulator${SDKVERSION}"

echo "Building simple-share for iPhoneSimulator and iPhoneOS ${SDKVERSION}"
# Clean the targets
if ! xcodebuild -project "simple-share.xcodeproj" -target simple-share -configuration "Release" -sdk "$DEVICESDK" clean ; then
	exit 1
fi
if ! xcodebuild -project "simple-share.xcodeproj" -target simple-share -configuration "Release" -sdk "$SIMSDK" clean ; then
	exit 1
fi

# Build the targets
if ! xcodebuild -project "simple-share.xcodeproj" -target simple-share -configuration "Release" -sdk "$DEVICESDK" -arch "armv6 armv7" build ; then
	exit 1
fi
if ! xcodebuild -project "simple-share.xcodeproj" -target simple-share -configuration "Release" -sdk "$SIMSDK" build ; then
	exit 1
fi

echo "Build library..."
lipo "build/Release-iphoneos/libsimple-share.a" "build/Release-iphonesimulator/libsimple-share.a" -create -output "libsimple-share.a"
cp -R build/Release-iphoneos/include .
echo "Building done."
