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
SOCK=$(ls /private/tmp/com.apple.launchd.*/com.apple.webinspectord_sim.socket | head -1)
echo SOCK $SOCK
ios_webkit_debug_proxy -s unix:$SOCK > $OUT/iwdp.txt 2>&1 &
sleep 5
xcrun simctl launch --console-pty $UDID com.munfordvillesports.app > $OUT/stdout1.txt 2>&1 &
sleep 20
node debug/inspect.js run1
xcrun simctl io $UDID screenshot $OUT/launch1.png
xcrun simctl terminate $UDID com.munfordvillesports.app
sleep 3
xcrun simctl launch --console-pty $UDID com.munfordvillesports.app > $OUT/stdout2.txt 2>&1 &
sleep 20
node debug/inspect.js run2 noreload
xcrun simctl io $UDID screenshot $OUT/launch2.png
echo ===== STDOUT1
grep -a -E 'rror|ailed|Loading app|WebView|native' $OUT/stdout1.txt | head -60
echo ===== STDOUT2
grep -a -E 'rror|ailed|Loading app|WebView|native' $OUT/stdout2.txt | head -60
echo ===== IWDP
tail -20 $OUT/iwdp.txt
exit 0
