"""Patches the android/ folder that `flutter create` generates in the cloud.

- Adds the INTERNET (and old-Android storage) permission and sets the app label.
- Adds the AdMob application ID (ADMOB_APP_ID overrides the one below).
- Adds R8 keep rules (tool/proguard-rules.pro) so release builds don't crash.
- Signs release builds with the Play upload key when android/key.properties
  exists; otherwise release builds keep using the debug key.
"""

import os
import re
import shutil
import sys
from pathlib import Path

ADMOB_APP_ID = "ca-app-pub-6267106725130019~8730544784"

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
gradle_path = Path("android/app/build.gradle.kts")
proguard_source = Path(__file__).with_name("proguard-rules.pro")
# The Flutter Gradle plugin applies this file to release builds automatically.
proguard_target = Path("android/app/proguard-rules.pro")


def patch_manifest() -> None:
    text = manifest_path.read_text()

    if "android.permission.INTERNET" not in text:
        text = text.replace(
            "<application",
            '<uses-permission android:name="android.permission.INTERNET"/>\n    <application',
            1,
        )

    # Saving to the gallery on Android 10 and older needs storage access.
    if "android.permission.WRITE_EXTERNAL_STORAGE" not in text:
        text = text.replace(
            "<application",
            '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"'
            ' android:maxSdkVersion="29"/>\n    <application',
            1,
        )

    text = re.sub(r'android:label="[^"]*"', 'android:label="Gurbani Wallpapers"', text, count=1)

    app_id = os.environ.get("ADMOB_APP_ID", "").strip() or ADMOB_APP_ID
    if not re.fullmatch(r"ca-app-pub-\d{16}~\d{10}", app_id):
        sys.exit(f"Invalid AdMob app ID: {app_id}")
    if "com.google.android.gms.ads.APPLICATION_ID" not in text:
        text = text.replace(
            "</application>",
            "    <meta-data\n"
            '            android:name="com.google.android.gms.ads.APPLICATION_ID"\n'
            f'            android:value="{app_id}"/>\n'
            "    </application>",
            1,
        )

    manifest_path.write_text(text)


def patch_gradle() -> None:
    text = gradle_path.read_text()
    if "keystoreProperties" in text:
        return

    debug_signing = 'signingConfig = signingConfigs.getByName("debug")'
    if debug_signing not in text or "\nandroid {" not in text:
        sys.exit("Unexpected build.gradle.kts layout; signing not configured.")

    header = (
        "import java.io.FileInputStream\n"
        "import java.util.Properties\n\n"
    )
    loader = (
        "val keystoreProperties = Properties()\n"
        'val keystorePropertiesFile = rootProject.file("key.properties")\n'
        "if (keystorePropertiesFile.exists()) {\n"
        "    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n"
        "}\n\n"
        "android {\n"
        "    signingConfigs {\n"
        '        create("release") {\n'
        "            if (keystorePropertiesFile.exists()) {\n"
        '                keyAlias = keystoreProperties["keyAlias"] as String\n'
        '                keyPassword = keystoreProperties["keyPassword"] as String\n'
        '                storeFile = file(keystoreProperties["storeFile"] as String)\n'
        '                storePassword = keystoreProperties["storePassword"] as String\n'
        "            }\n"
        "        }\n"
        "    }\n"
    )
    text = header + text.replace("\nandroid {\n", "\n" + loader, 1)
    text = text.replace(
        debug_signing,
        "signingConfig = if (keystorePropertiesFile.exists()) "
        'signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
        1,
    )
    gradle_path.write_text(text)


patch_manifest()
patch_gradle()
shutil.copyfile(proguard_source, proguard_target)
print(manifest_path.read_text())
