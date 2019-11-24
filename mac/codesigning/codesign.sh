#!/bin/sh

source app_store_credentials

# Copy in HelloWorld3.app from where we built it
rm -rf HelloWorld3.app
cp -r ../dist/HelloWorld3.app HelloWorld3.app

# Remove "Finder detritus" from files in the app bundle
xattr -cr HelloWorld3.app

# Remove files that code-signing doesn't like and the app seems to work without
rm HelloWorld3.app/Contents/Frameworks/**/*.prl
rm -rf HelloWorld3.app/Contents/Frameworks/QtUiPlugin.framework

# Add a "Current" symlink to each framework, so codesigning knows the current version
for f in HelloWorld3.app/Contents/Frameworks/*/Versions
do
  ( cd $f; ln -s * Current )
done

# Codesign the app
codesign --options=runtime -s "$SIGNING_IDENTITY" -v --timestamp --deep --force HelloWorld3.app

# Submit app for notarization
ditto -c -k --keepParent HelloWorld3.app HelloWorld3_fornotarization.zip
xcrun altool --notarize-app --primary-bundle-id com.manning.sande3 --username "$APP_STORE_USERNAME" --password "$APP_STORE_PASSWORD" --asc-provider "$APP_STORE_PROVIDER" --file HelloWorld3_fornotarization.zip