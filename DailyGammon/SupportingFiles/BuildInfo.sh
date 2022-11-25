#!/bin/sh

# Set build number and version in derived data, avoid frequent changes in info.plist.

plist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
git=`sh /etc/profile; which git`

# Counter of all git commits (across branches) used to ensure a unique build number (App Store Connect requirement)

appBuild=`"$git" rev-list --all --count`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $appBuild" "$plist"
echo "Updated $plist build number to $appBuild"

# Take the app version from a git tag of the current branch, e.g. "1.4.3"

gitinfo=`"$git" describe --tags --always --long`
appVersion=`echo ${gitinfo} | awk -F'-' '{print $1}'`
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $appVersion" "$plist"
echo "Updated $plist build version to $appVersion"

# git hash saved in info.plist to identify related commits more easily

gitHash=`"$git" rev-parse --short HEAD`
/usr/libexec/PlistBuddy -c "Add :DGCommit string $gitHash" "$plist"
echo -e "DGCommit set to $gitHash"

# Update the versions info in app settings; offset to be adjusted if number of settings changes

settingPlist="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Settings.bundle/Root.plist"
if [ -f "${settingPlist}" ]
then
    /usr/libexec/PlistBuddy -c "set PreferenceSpecifiers:5:DefaultValue $appVersion ($appBuild)" "${settingPlist}"
    echo -e "Settings.bundle set to $appVersion ($appBuild)"
else
    echo -e "Can't find the settings' plist: ${settingPlist}"
fi
