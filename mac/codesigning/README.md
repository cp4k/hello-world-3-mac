# Code Signing / Notarization

This doesn't happen automatically, but it's needed for the app to run without scary pop-up messages on recent versions of macOS.

**Code signing** is a process that happens (almost) entirely on your own computer. You take your private key and the certificate Apple gave you, and you add a digital signature to the app. **Notarization** means sending your (signed) app to Apple so they can give the OK.

For both processes, you'll need an Apple Developer account, which you can buy for $99/year at developer.apple.com

## How to code-sign/notarize

1. Put your App Store Connect credentials in a file called `app_store_credentials`. (See `app_store_credentials.sample`.)
2. After building the app, run `./codesign.sh` to sign it and send it to Apple for notarization.
3. Wait for Apple to notarize your app. They'll send you an email when it's done, or you can run `xcrun --notarization-info [the UUID they gave you] --username [x] --password [x]`
4. (Technically optional?) Run `./postnotarizesuccess.sh` to staple your notarization to the app and make a zip file you can send people.