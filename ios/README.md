# Mochy iOS port

This folder is the native iPhone/iPad port of **Mochy Music**. It is based on
[Mochy Music by realidkroo](https://github.com/realidkroo/Mochy-Music) and is
distributed under the repository's GPL-3.0 license.

## Current foundation

- SwiftUI interface designed for iPhone, with Listen, Search, Library, mini-player, and Now Playing views.
- HTTPS direct audio/HLS playback through `AVPlayer`.
- Background audio, lock-screen metadata, play/pause, and seek controls.
- GitHub Actions workflow that produces a signed development or Ad Hoc IPA on `macos-latest`.

This is not yet feature parity with Android. Android-specific providers, catalogue search,
downloads, lyrics, offline library, imports, EQ, and account integrations must be ported and
validated source-by-source. Only use media sources and APIs whose terms permit the intended use.

## Run locally on a Mac

Open `MochyIOS/MochyIOS.xcodeproj` in Xcode, set your unique bundle identifier and Apple team,
then select an iPhone 13 (or simulator) and Run. The deployment target is iOS 16.0.

## Build an installable IPA from GitHub Actions

Run **Build iOS IPA** manually and choose `development` or `ad-hoc`. Add these repository secrets:

| Secret | Meaning |
| --- | --- |
| `IOS_CERTIFICATE_BASE64` | Base64 of an Apple Development or Apple Distribution `.p12` certificate |
| `IOS_CERTIFICATE_PASSWORD` | Password used when exporting that `.p12` |
| `IOS_PROVISION_PROFILE_BASE64` | Base64 of a matching development or Ad Hoc `.mobileprovision` |
| `IOS_KEYCHAIN_PASSWORD` | A fresh, random password used only for CI's temporary keychain |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID |
| `IOS_BUNDLE_IDENTIFIER` | The App ID covered by that provisioning profile, e.g. `com.yourname.mochyios` |

For a Development IPA, register the iPhone 13 UDID in the development profile. For an Ad Hoc IPA,
use an Ad Hoc distribution certificate/profile and register the device UDID there. GitHub Actions
uploads the signed `.ipa` as an artifact; downloading it alone does not bypass iOS signing rules.
