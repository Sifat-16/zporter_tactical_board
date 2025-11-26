#!/bin/bash

# Exit immediately if a command fails
set -e

echo "🚀 Welcome to the Build Launcher!"
echo ""
echo "Please choose your build type:"
echo "  1) Shorebird Release (Android)"
echo "  2) Shorebird Release (iOS)"
echo "  3) Shorebird Patch (Android)"
echo "  4) Shorebird Patch (iOS)"
echo "  5) Flutter Build APK (Release)"
echo "  6) Flutter Build App Bundle (AAB)"
echo "  7) Flutter Build IPA (iOS)"
echo "  8) Exit"

read -p "Enter your choice [1-8]: " BUILD_CHOICE

# --- Confirmation Step ---
if [[ "$BUILD_CHOICE" != "8" ]]; then
    echo ""
    read -p "⚠️ Have you manually updated the version in pubspec.yaml and AppInfo.dart? (yes/no): " CONFIRMATION
    # Convert confirmation to lowercase
    CONFIRMATION=${CONFIRMATION,,}

    if [[ "$BUILD_CHOICE" != "8" && "$CONFIRMATION" != "yes" && "$CONFIRMATION" != "y" ]]; then
        echo "❌ Build aborted. Please update the version information before running the script again."
        exit 1
    fi
    echo ""
fi

# --- Execute Build Command Based on Choice ---
case $BUILD_CHOICE in
  1)
    echo "🚀 Starting Shorebird Release (Android)..."
    shorebird release android -- --no-tree-shake-icons
    ;;
  2)
    echo "🚀 Starting Shorebird Release (iOS)..."
    shorebird release ios -- --no-tree-shake-icons
    ;;
  3)
    echo "🚀 Starting Shorebird Patch (Android)..."
    shorebird patch android -- --no-tree-shake-icons
    ;;
  4)
    echo "🚀 Starting Shorebird Patch (iOS)..."
    shorebird patch ios -- --no-tree-shake-icons
    ;;
  5)
    echo "📦 Starting Flutter APK Build..."
    flutter build apk --release --no-tree-shake-icons
    ;;
  6)
    echo "📦 Starting Flutter App Bundle (AAB) Build..."
    flutter build appbundle --release --no-tree-shake-icons
    ;;
  7)
    echo "🍎 Starting Flutter IPA (iOS) Build..."
    flutter build ipa --release --no-tree-shake-icons
    ;;
  8)
    echo "👋 Exiting build script."
    exit 0
    ;;
  *)
    echo "❌ Invalid choice. Please run the script again."
    exit 1
    ;;
esac

echo ""
echo "🎉 Build process complete!"