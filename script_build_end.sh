#!/bin/sh

plist="${CONFIGURATION_BUILD_DIR}/${INFOPLIST_PATH}"

# http://blog.jaredsinclair.com/post/97193356620/the-best-of-all-possible-xcode-automated-build

update_bundle_version()
{
git=`sh /etc/profile; which git`
build=`"$git" rev-list --all |wc -l`
if [[ $CONFIGURATION == *Debug* ]]; then
branch=`"$git" rev-parse --abbrev-ref HEAD`
version=$build-$branch
else
version=$build
fi
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "${plist}"
echo Build version set to git specs: $version
}

update_build_date()
{
CFBuildDate=$(date +"%y.%m.%d %H:%M:%S %Z")
/usr/libexec/PlistBuddy -c "Set :CFBuildDate $CFBuildDate" "${plist}"
echo Build date set to current date: $CFBuildDate
}

# do build post-processing

echo Setting info in plist $plist:

update_bundle_version
update_build_date

# finished

return 0
