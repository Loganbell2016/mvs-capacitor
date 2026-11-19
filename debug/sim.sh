OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install > /dev/null 2>&1
npx cap add ios > /dev/null 2>&1
npx cap sync ios > /dev/null 2>&1
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build | tail -2
APP=/tmp/dd/Build/Products/Release-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b > /dev/null
xcrun simctl install $UDID $APP
for n in 1 2 3 4 5; do
echo ===== LAUNCH $n
xcrun simctl launch $UDID com.munfordvillesports.app > /dev/null
sleep 20
xcrun simctl io $UDID screenshot $OUT/l$n.png > /dev/null 2>&1
sips -Z 300 -s format jpeg -s formatOptions 40 $OUT/l$n.png --out $OUT/l$n.jpg > /dev/null
echo SCREENSHOT BYTES $(wc -c < $OUT/l$n.jpg)
APID=$(pgrep -x App | tail -1)
echo APP MAIN THREAD
sample $APID 1 2>/dev/null | sed -n '/com.apple.main-thread/,+30p' | grep -vE 'start|dyld|UIApplicationMain|GSEventRun|CFRunLoopRun|__CFRunLoop|mach_msg' | cut -c1-170 | head -15
echo WEBKIT LOG
xcrun simctl spawn $UDID log show --last 25s --style compact --predicate 'subsystem == "com.apple.WebKit"' 2>/dev/null | grep -iE 'suspend|throttl|assertion|crash|terminat|unresponsive|hang|visib|occlu|freeze|fail' | cut -c1-230 | tail -20
xcrun simctl terminate $UDID com.munfordvillesports.app
sleep 3
done
exit 0
