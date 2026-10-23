# Gurbani Wallpapers

Find a line of Gurbani and turn it into a phone wallpaper or a WhatsApp/Instagram status image.

- All Gurbani comes live from the [BaniDB API](https://api.banidb.com/v2) by Khalis Foundation and is shown exactly as returned. The app contains no Gurbani text of its own, and the text cannot be edited.
- You can only change the background (calm gradients), font, size and position.
- The Android app shows one small banner ad at the bottom of the screen (Google AdMob, family-safe ads only). Ads never appear on the wallpaper itself. The web version has no ads.

## How the cloud build works

You don't need Flutter or Android Studio on your computer. Everything is built by GitHub Actions (`.github/workflows/build.yml`) on every push to `main`, or when you run it by hand from the **Actions** tab ("Build Gurbani Wallpapers" → **Run workflow**).

The workflow:

1. Sets up Java 17 and the stable Flutter SDK.
2. Runs `flutter create .` to generate the `android/` and `web/` folders. They are not stored in this repository.
3. Adds the internet permission and sets the app name to "Gurbani Wallpapers".
4. Runs `flutter analyze` and the tests.
5. Builds a release APK (**android-test-app** artifact) and a Google Play bundle (**play-store-bundle** artifact).
6. Builds the web version and publishes it to GitHub Pages, together with the privacy policy at `/privacy.html`.

### One-time setup for the web version

In the repository, go to **Settings → Pages → Build and deployment → Source** and choose **GitHub Actions**. Then re-run the workflow. The site will be at `https://<your-username>.github.io/<repository-name>/`.

## Getting the Android app

1. Open the **Actions** tab and click the latest green run.
2. Under **Artifacts**, download **android-test-app** (a zip file).
3. Unzip it and copy `app-release.apk` to your Android phone, then open it and allow "Install unknown apps" when asked.

## Ads and Google Play

Until you add your own IDs, the app shows Google's **test ads**, and the Play bundle is signed with a debug key that Google Play won't accept.

In the repository, open **Settings → Secrets and variables → Actions**.

**Variables** tab (your AdMob IDs):

| Name | Value |
| --- | --- |
| `ADMOB_APP_ID` | AdMob app ID, looks like `ca-app-pub-1234567890123456~1234567890` |
| `ADMOB_BANNER_ID` | AdMob banner ad unit ID, looks like `ca-app-pub-1234567890123456/1234567890` |

**Secrets** tab (your Play upload key):

| Name | Value |
| --- | --- |
| `UPLOAD_KEYSTORE_BASE64` | The upload keystore file, base64-encoded (key alias `upload`) |
| `UPLOAD_KEYSTORE_PASSWORD` | The keystore password |

Then run the workflow again and upload `app-release.aab` from **play-store-bundle** in Play Console. Each run gets a new version code automatically.

Privacy policy URL for Play Console and AdMob: `https://<your-username>.github.io/<repository-name>/privacy.html`

## Project layout

- `lib/services/banidb_service.dart`: BaniDB search and random shabad calls
- `lib/models/verse.dart`: careful parsing of the API response
- `lib/screens/`: search and editor screens
- `lib/wallpaper/`: the 360×780 wallpaper canvas, backgrounds and fonts
- `lib/ads/`: AdMob banner and consent (mobile only; empty on web)
- `tool/configure_android.py`: patches the generated `android/` folder in the cloud
- `pages/privacy.html`: privacy policy published with the web version
