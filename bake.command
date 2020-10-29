#!/bin/bash
cd "$(dirname "$0")"
rm -rf DeliveredBakeData
rm -rf artifacts
mkdir DeliveredBakeData
rsync -av --progress ./ ./DeliveredBakeData --exclude DeliveredBakeData
cd DeliveredBakeData
SAFELOCATION=$(pwd) && echo $SAFELOCATION
rm -rf artifacts
mkdir artifacts

cd $SAFELOCATION/SpringBoardInjector/DesktopLyricOverlay
rm -rf Packages/*
xcodebuild clean build -destination generic/platform=iOS \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED="NO" \
  MonkeyDevInstallOnProfiling="NO" \
  MonkeyDevInstallOnAnyBuild="NO" \
  MonkeyDevCopyOnBuild="NO" \
  MonkeyDevClearUiCacheOnInstall="NO" \
  MonkeyDevBuildPackageOnAnyBuild="YES" \
  | xcpretty
cp Packages/*.deb $SAFELOCATION/artifacts/

cd $SAFELOCATION/NMRoutine/NeteaseMusicLyricProvider
rm -rf Packages/*
xcodebuild clean build -destination generic/platform=iOS \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED="NO" \
  MonkeyDevInstallOnProfiling="NO" \
  MonkeyDevInstallOnAnyBuild="NO" \
  MonkeyDevCopyOnBuild="NO" \
  MonkeyDevClearUiCacheOnInstall="NO" \
  MonkeyDevBuildPackageOnAnyBuild="YES" \
  | xcpretty
cp Packages/*.deb $SAFELOCATION/artifacts/

cd $SAFELOCATION/QQMusicRoutine/QQMusicLyricsProvider
rm -rf Packages/*
xcodebuild clean build -destination generic/platform=iOS \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED="NO" \
  MonkeyDevInstallOnProfiling="NO" \
  MonkeyDevInstallOnAnyBuild="NO" \
  MonkeyDevCopyOnBuild="NO" \
  MonkeyDevClearUiCacheOnInstall="NO" \
  MonkeyDevBuildPackageOnAnyBuild="YES" \
  | xcpretty
cp Packages/*.deb $SAFELOCATION/artifacts/

cd $SAFELOCATION/BigBossConnect
rm -rf temp && mkdir temp
cd temp
cp $SAFELOCATION/SpringBoardInjector/DesktopLyricOverlay/Packages/*.zip .
cp $SAFELOCATION/NMRoutine/NeteaseMusicLyricProvider/Packages/*.zip .
cp $SAFELOCATION/QQMusicRoutine/QQMusicLyricsProvider/Packages/*.zip .
for i in *.zip; do unzip -o $i; done
cd ..
cp ./temp/Library/MobileSubstrate/DynamicLibraries/*.dylib ./nmlrc/Library/MobileSubstrate/DynamicLibraries/
cp ./temp/Library/MobileSubstrate/DynamicLibraries/*.plist ./nmlrc/Library/MobileSubstrate/DynamicLibraries/
mkdir -p ./nmlrc/Library/PreferenceLoader/Preferences
cp ./temp/Library/PreferenceLoader/Preferences/* ./nmlrc/Library/PreferenceLoader/Preferences
cd nmlrc
find . -exec ldid -S {} + &> /dev/null || true
dpkg-deb -Zgzip -b . ../nmlrc.deb
cd $SAFELOCATION
mv BigBossConnect/nmlrc.deb artifacts/
cd $SAFELOCATION
ls -la artifacts
for i in artifacts/*.deb; do dpkg -I $i; done
cd ..
mv ./DeliveredBakeData/artifacts ./
rm -rf DeliveredBakeData

echo "Result is at: $(pwd)"

