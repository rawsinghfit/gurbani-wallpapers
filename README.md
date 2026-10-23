# Gurbani Wallpapers

Find a line of Gurbani and turn it into a phone wallpaper or a WhatsApp/Instagram status image.

- All Gurbani comes live from the [BaniDB API](https://api.banidb.com/v2) by Khalis Foundation and is shown exactly as returned. The app contains no Gurbani text of its own, and the text cannot be edited.
- You can only change the background (calm gradients), font, size and position.
- No ads.

## How the cloud build works

You don't need Flutter or Android Studio on your computer. Everything is built by GitHub Actions (`.github/workflows/build.yml`) on every push to `main`, or when you run it by hand from the **Actions** tab ("Build Gurbani Wallpapers" → **Run workflow**).

The workflow:

1. Sets up Java 17 and the stable Flutter SDK.
2. Runs `flutter create .` to generate the `android/` and `web/` folders. They are not stored in this repository.
3. Adds the internet permission and sets the app name to "Gurbani Wallpapers".
4. Runs `flutter analyze` and the tests.
5. Builds a release APK and uploads it as the **android-test-app** artifact.
6. Builds the web version and publishes it to GitHub Pages.

### One-time setup for the web version

In the repository, go to **Settings → Pages → Build and deployment → Source** and choose **GitHub Actions**. Then re-run the workflow. The site will be at `https://<your-username>.github.io/<repository-name>/`.

## Getting the Android app

1. Open the **Actions** tab and click the latest green run.
2. Under **Artifacts**, download **android-test-app** (a zip file).
3. Unzip it and copy `app-release.apk` to your Android phone, then open it and allow "Install unknown apps" when asked.

## Project layout

- `lib/services/banidb_service.dart`: BaniDB search and random shabad calls
- `lib/models/verse.dart`: careful parsing of the API response
- `lib/screens/`: search and editor screens
- `lib/wallpaper/`: the 360×780 wallpaper canvas, backgrounds and fonts
