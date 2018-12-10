#!/bin/sh

#  BuildInfo.sh
#  Golf
#
#  Created by Peter on 08.02.13.
#
#buildPlist="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
#buildNumber=$(/usr/libexec/PlistBuddy -c "Print DGbuildNumber" "$buildPlist")
#buildNumber=$(($buildNumber + 1))
#/usr/libexec/PlistBuddy -c "Set :DGbuildNumber $buildNumber" "$buildPlist"
#CFBuildDate=$(date +"%d.%m.%Y %H:%M:%S")
#/usr/libexec/PlistBuddy -c "Set :DGbuildDate $CFBuildDate" "$buildPlist"

buildPlist="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
CFBuildDate=$(date +"%d. %B %Y %H:%M:%S")
#CFBuildDate=$(date +"%d.%m.%Y %H:%M:%S")
/usr/libexec/PlistBuddy -c "Set :DGBuildDate $CFBuildDate" "$buildPlist"
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
