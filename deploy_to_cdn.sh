#!/bin/bash

# =============================================================================
# Flutter Tactical Board - CDN Deployment Script
# =============================================================================
# This script builds the Flutter tactical board for web and deploys it to
# Firebase Hosting (CDN). This is the recommended way to deploy the widget
# instead of copying files to the web repository.
#
# Usage: ./deploy_to_cdn.sh [--skip-build] [--project PROJECT_ID]
#   --skip-build           Skip Flutter build, just deploy existing build
#   --project PROJECT_ID   Firebase project to deploy to (default: zporter-board-dev)
#
# Prerequisites:
#   - Firebase CLI (uses npx firebase-tools@13.0.0 for Node 18 compatibility)
#   - Firebase login (run: npx firebase-tools@13.0.0 login)
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$FLUTTER_PROJECT_DIR/build/web"
BASE_HREF="/"  # Root path since widget is at CDN root
FIREBASE_PROJECT="zporter-board-dev"
FIREBASE_CLI="npx firebase-tools@13.0.0"  # Use v13 for Node 18 compatibility

# Parse arguments
SKIP_BUILD=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --project)
            FIREBASE_PROJECT="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Flutter Tactical Board CDN Deploy${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}📡 Firebase Project: ${NC}$FIREBASE_PROJECT"
echo -e "${BLUE}🌐 CDN URL: ${NC}https://${FIREBASE_PROJECT}.web.app"
echo ""

# Step 1: Check Firebase login status
echo -e "${BLUE}🔐 Checking Firebase authentication...${NC}"
if ! $FIREBASE_CLI projects:list --project "$FIREBASE_PROJECT" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not logged in to Firebase. Running login...${NC}"
    $FIREBASE_CLI login
fi
echo -e "${GREEN}✅ Firebase authenticated${NC}"

# Step 2: Navigate to Flutter project
echo ""
echo -e "${BLUE}📁 Project directory: ${NC}$FLUTTER_PROJECT_DIR"
cd "$FLUTTER_PROJECT_DIR"

# Step 3: Build Flutter web (unless skipped)
if [[ "$SKIP_BUILD" == false ]]; then
    echo ""
    echo -e "${BLUE}🔨 Building Flutter web...${NC}"
    echo -e "${YELLOW}   Base href: ${NC}$BASE_HREF"
    
    flutter build web --release --base-href "$BASE_HREF"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Flutter build failed!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Flutter build completed${NC}"
else
    echo ""
    echo -e "${YELLOW}⏭️  Skipping Flutter build (--skip-build flag)${NC}"
fi

# Step 4: Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}❌ Build directory not found: $BUILD_DIR${NC}"
    echo -e "${RED}   Run without --skip-build flag to build first${NC}"
    exit 1
fi

# Step 5: Security check - verify Firebase Hosting will filter sensitive files
echo ""
echo -e "${BLUE}🔒 Security check...${NC}"

# Check if sensitive files exist in build
FOUND_SENSITIVE=false
if find "$BUILD_DIR" -path "*/assets/secure/*" 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}⚠️  Found files in assets/secure/ folder${NC}"
    FOUND_SENSITIVE=true
fi

# Verify firebase.json has proper ignore rules
if grep -qF '"**/assets/secure/**"' firebase.json; then
    if [ "$FOUND_SENSITIVE" = true ]; then
        echo -e "${GREEN}✅ firebase.json will exclude assets/secure/** from deployment${NC}"
        echo -e "${BLUE}   Files in assets/secure/ will NOT be publicly accessible${NC}"
    else
        echo -e "${GREEN}✅ No sensitive files detected in build${NC}"
    fi
else
    echo -e "${RED}❌ CRITICAL: firebase.json missing assets/secure/** ignore rule!${NC}"
    echo -e "${RED}   Add this to firebase.json hosting.ignore:${NC}"
    echo -e "${RED}   \"**/assets/secure/**\"${NC}"
    exit 1
fi

# Additional check: warn about other service account patterns outside secure folder
if find "$BUILD_DIR" -name "*service_account*.json" ! -path "*/assets/secure/*" 2>/dev/null | grep -q .; then
    echo -e "${RED}❌ CRITICAL: Service account file found OUTSIDE secure folder!${NC}"
    find "$BUILD_DIR" -name "*service_account*.json" ! -path "*/assets/secure/*"
    echo -e "${RED}This file will be publicly accessible! Aborting deployment.${NC}"
    exit 1
fi

# Step 6: Deploy to Firebase Hosting
echo ""
echo -e "${BLUE}🚀 Deploying to Firebase Hosting...${NC}"
$FIREBASE_CLI deploy --only hosting --project "$FIREBASE_PROJECT"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Firebase deployment failed!${NC}"
    exit 1
fi

# Step 7: Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "CDN URL: ${GREEN}https://${FIREBASE_PROJECT}.web.app${NC}"
echo -e "Alt URL: ${GREEN}https://${FIREBASE_PROJECT}.firebaseapp.com${NC}"
echo ""
echo -e "To use this CDN in the web app, set:"
echo -e "  ${YELLOW}NEXT_PUBLIC_FLUTTER_CDN_URL=https://${FIREBASE_PROJECT}.web.app${NC}"
echo ""

# Show file count
FILE_COUNT=$(find "$BUILD_DIR" -type f | wc -l | tr -d ' ')
echo -e "Total files deployed: ${GREEN}$FILE_COUNT${NC}"
