set -x
OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install
npm install ws --no-save
npx cap add ios
npx cap sync ios
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build | tail -5
APP=/tmp/dd/Build/Products/Debug-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b
xcrun simctl install $UDID $APP
brew install ios-webkit-debug-proxy > /dev/null 2>&1
SOCK=$(lsof -aUc launchd_sim 2>/dev/null | grep 'com.apple.webinspectord_sim.socket' | head -1 | awk '{print $NF}')
ios_webkit_debug_proxy -s unix:$SOCK > $OUT/iwdp.txt 2>&1 &
sleep 5
xcrun simctl launch $UDID com.munfordvillesports.app
sleep 12
node debug/inspect.js run1
xcrun simctl io $UDID screenshot $OUT/a1.png
set +x
sips -Z 520 -s format jpeg -s formatOptions 55 $OUT/a1.png --out $OUT/a1.jpg > /dev/null
echo B64a1-START
base64 -b 100 -i $OUT/a1.jpg
echo B64a1-END
exit 0
