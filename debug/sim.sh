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
xcrun simctl launch --console-pty $UDID com.munfordvillesports.app > $OUT/stdout1.txt 2>&1 &
sleep 15
node debug/inspect.js run1
xcrun simctl io $UDID screenshot $OUT/launch1.png
xcrun simctl terminate $UDID com.munfordvillesports.app
sleep 3
xcrun simctl launch --console-pty $UDID com.munfordvillesports.app > $OUT/stdout2.txt 2>&1 &
sleep 15
node debug/inspect.js run2 noreload
xcrun simctl io $UDID screenshot $OUT/launch2.png
set +x
sips -Z 520 -s format jpeg -s formatOptions 55 $OUT/launch1.png --out $OUT/s1.jpg > /dev/null
sips -Z 520 -s format jpeg -s formatOptions 55 $OUT/launch2.png --out $OUT/s2.jpg > /dev/null
echo B64S1-START
base64 -b 100 -i $OUT/s1.jpg
echo B64S1-END
echo B64S2-START
base64 -b 100 -i $OUT/s2.jpg
echo B64S2-END
echo ===== STDOUT1
cut -c1-300 $OUT/stdout1.txt | head -60
echo ===== STDOUT2
cut -c1-300 $OUT/stdout2.txt | head -60
exit 0
