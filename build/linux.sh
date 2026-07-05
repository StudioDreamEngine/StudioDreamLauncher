#!/usr/bin/env bash

COMPILED="./compiled"
DIST="../dist"

python3 compile.py

chmod +x appimagetool.AppImage

# Create the love archive
echo Creating build...
cd $COMPILED
zip -9 -r ../StudioDreamLauncher.love . -x "./CLibraries/*"
cd $OLDPWD

# We need to make sure the appimage is executable
./love.AppImage --appimage-extract

SQUASH_ROOT="./squashfs-root"
LIBRARIES="$SQUASH_ROOT/lib/studio-dream/"
EXTERNAL="$SQUASH_ROOT/share/studio-dream/"

# Setup appimage
cp AppRun "$SQUASH_ROOT/AppRun"
cp love.desktop "$SQUASH_ROOT/love.desktop"
cp -r "./icon.png" "$SQUASH_ROOT/icon.png"

# Setup executable
cat "$SQUASH_ROOT/bin/love" StudioDreamLauncher.love > "$SQUASH_ROOT/bin/StudioDream"
chmod +x "$SQUASH_ROOT/bin/StudioDream"

# Setup dependencies
mkdir $LIBRARIES
cp -r "$COMPILED/CLibraries/linux/." $LIBRARIES

# Cleanup
rm "$SQUASH_ROOT/love.svg"
rm "StudioDreamLauncher.love"

# Build appimage
echo Building AppImage..
./appimagetool.AppImage $SQUASH_ROOT "$DIST/StudioDreamLauncher.AppImage"

echo
echo Done! Built AppImage is within dist
