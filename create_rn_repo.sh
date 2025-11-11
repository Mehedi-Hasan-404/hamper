#!/usr/bin/env bash
set -euo pipefail

# Simple script to create a minimal React Native native-cli Android project
# in current directory (folder name will be created), commit it to git,
# and optionally push to a GitHub remote.
#
# Run in Termux:
# chmod +x create_rn_repo.sh
# ./create_rn_repo.sh

# --- Configurable project name ---
DEFAULT_DIR="hello-world-rn"

read -r -p "Project directory name [${DEFAULT_DIR}]: " PROJECT_DIR
PROJECT_DIR="${PROJECT_DIR:-$DEFAULT_DIR}"

read -r -p "GitHub repo HTTPS URL to push to (leave blank to skip push): " GITHUB_REPO

echo "Creating project in ./${PROJECT_DIR} ..."

# create structure
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# create .gitignore
cat > .gitignore <<'EOF'
node_modules/
android/.gradle/
android/app/build/
*.log
.env
.DS_Store
EOF

# package.json
cat > package.json <<'EOF'
{
  "name": "hello-world-rn",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "start": "react-native start",
    "android": "react-native run-android"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.71.8"
  }
}
EOF

# index.js
cat > index.js <<'EOF'
import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from './app.json';
AppRegistry.registerComponent(appName, () => App);
EOF

# app.json
cat > app.json <<'EOF'
{ "name": "HelloWorldRN", "displayName": "HelloWorldRN" }
EOF

# App.js
cat > App.js <<'EOF'
import React from 'react';
import { SafeAreaView, Text, StyleSheet, StatusBar } from 'react-native';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <Text style={styles.title}>Hello, World!</Text>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center', padding: 16 },
  title: { fontSize: 32, fontWeight: '700', color: '#111' }
});
EOF

# README.md
cat > README.md <<'EOF'
# Hello World React Native (native CLI) - minimal

This repository is a minimal React Native (Android) project showing "Hello, World!" on launch.

How to use (short):
1. Run: npm install
2. To build on a machine with Android SDK: npx react-native run-android

Notes:
- Building locally on Android (Termux) requires Android SDK, Java JDK, and Gradle. On Termux this setup is advanced.
- For a simple cloud build, push this repo to GitHub and use CI (GitHub Actions) or other cloud builder.
EOF

# create android tree
mkdir -p android/gradle/wrapper
mkdir -p android/app/src/main/java/com/example/helloworld

# settings.gradle
cat > android/settings.gradle <<'EOF'
rootProject.name = 'HelloWorldRN'
include ':app'
EOF

# android/build.gradle
cat > android/build.gradle <<'EOF'
// Top-level build file
buildscript {
    ext {
        buildToolsVersion = "33.0.2"
        minSdkVersion = 21
        compileSdkVersion = 33
        targetSdkVersion = 33
    }
    repositories {
        mavenCentral()
        google()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.1")
    }
}
allprojects {
    repositories {
        mavenCentral()
        google()
    }
}
EOF

# gradle-wrapper.properties
cat > android/gradle/wrapper/gradle-wrapper.properties <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
EOF

# Create a minimal gradlew script (POSIX)
cat > android/gradlew <<'EOF'
#!/usr/bin/env sh
# Minimal gradlew stub. In CI or local machine you usually have the full Gradle wrapper.
# This script will attempt to use system gradle if available.
if command -v gradle >/dev/null 2>&1; then
  gradle "$@"
else
  echo "No system 'gradle' found. To run builds, either install Gradle or generate the gradle wrapper (gradle/wrapper/gradle-wrapper.jar)."
  echo "You can download a gradle wrapper JAR on a desktop and place it at android/gradle/wrapper/gradle-wrapper.jar"
  exit 1
fi
EOF
chmod +x android/gradlew

# android/app/build.gradle
cat > android/app/build.gradle <<'EOF'
apply plugin: "com.android.application"

android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.example.helloworld"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation fileTree(dir: "libs", include: ["*.jar"])
    implementation "com.facebook.react:react-native:+"
}
EOF

# AndroidManifest.xml
cat > android/app/src/main/AndroidManifest.xml <<'EOF'
<manifest package="com.example.helloworld" xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:allowBackup="true"
        android:label="HelloWorldRN"
        android:supportsRtl="true">
        <activity android:name=".MainActivity"
            android:exported="true"
            android:label="HelloWorldRN"
            android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# MainActivity.java
cat > android/app/src/main/java/com/example/helloworld/MainActivity.java <<'EOF'
package com.example.helloworld;

import android.os.Bundle;
import com.facebook.react.ReactActivity;

public class MainActivity extends ReactActivity {
    @Override
    protected String getMainComponentName() {
        return "HelloWorldRN";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(null);
    }
}
EOF

# MainApplication.java
cat > android/app/src/main/java/com/example/helloworld/MainApplication.java <<'EOF'
package com.example.helloworld;

import android.app.Application;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.soloader.SoLoader;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            List<ReactPackage> packages = new PackageList(this).getPackages();
            return packages;
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
    }
}
EOF

# Optional: create gradle wrapper dir for jar placeholder
mkdir -p android/gradle/wrapper

# Make sure everything is saved
echo "Files generated."

# Initialize git and commit
if [ ! -d ".git" ]; then
  git init
  git add .
  git commit -m "Initial React Native native-cli minimal HelloWorld"
  echo "Local git repo created and initial commit made."
else
  echo "Git repo already exists. Skipping git init/commit."
fi

# Add remote and push (if provided)
if [ -n "${GITHUB_REPO}" ]; then
  # check if remote already set
  if git remote | grep -q origin; then
    echo "Remote 'origin' already exists. Skipping adding remote."
  else
    git remote add origin "${GITHUB_REPO}"
    git branch -M main || true
  fi
  echo "Pushing to remote (origin main)..."
  git push -u origin main
  echo "Pushed to ${GITHUB_REPO}"
else
  echo "No GitHub repo URL provided; skipping push. You can add a remote later with:"
  echo "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  echo "  git push -u origin main"
fi

# Final notes
cat <<'NOTES'

DONE — basic project files created at ./${PROJECT_DIR}

IMPORTANT next steps / notes:
1) gradle-wrapper.jar is NOT included. To perform Gradle builds on CI or locally, either:
   - Generate wrapper on a desktop (run 'gradle wrapper') and commit the following files:
     - android/gradlew (you already have a small stub; replace it with the real gradlew if desired)
     - android/gradle/wrapper/gradle-wrapper.properties (already created)
     - android/gradle/wrapper/gradle-wrapper.jar  <-- REQUIRED
   - OR install Gradle on the machine that will build and use 'gradle' (the script will attempt to use system 'gradle').

2) To build an APK on a machine with Android SDK:
   - Run: npm install
   - Then (in android folder) run ./gradlew assembleRelease  (requires gradle wrapper jar or system gradle)

3) If you want the script to also download the gradle-wrapper.jar automatically, run the command below (on a device with internet and enough space):
   mkdir -p android/gradle/wrapper && \
   curl -L -o android/gradle/wrapper/gradle-wrapper.jar "https://services.gradle.org/distributions/gradle-7.5-bin.zip" \
   # Note: the official wrapper jar is inside a distribution zip; it's simpler to generate wrapper on desktop.
   # I do NOT download it automatically in this script to avoid large downloads without explicit consent.

4) Building in Termux directly is advanced. Recommended flows:
   - Push this repo to GitHub and use GitHub Actions / CI to run Gradle and produce APK (I can provide a workflow file).
   - Or clone repo on a desktop with Android SDK to produce a release APK.

If you want, I can now:
  A) add a GitHub Actions workflow (Y/n)? 
  B) provide a command to download / create the gradle-wrapper.jar (Y/n)?
  C) give a ready-to-add gradle-wrapper.jar base64 (big) (Y/n)?

Run this script again after making additional changes or adding gradle-wrapper.jar, etc.

NOTES
EOF

exit 0
