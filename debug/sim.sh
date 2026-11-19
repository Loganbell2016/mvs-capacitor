OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install > /dev/null 2>&1
npm install ws --no-save > /dev/null 2>&1
npx cap add ios > /dev/null 2>&1
npx cap sync ios > /dev/null 2>&1
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build | tail -3
APP=/tmp/dd/Build/Products/Debug-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b > /dev/null
xcrun simctl install $UDID $APP
brew install ios-webkit-debug-proxy > /dev/null 2>&1
brew tap facebook/fb > /dev/null 2>&1
brew install idb-companion 2>&1 | tail -3
pip3 install fb-idb --break-system-packages > /dev/null 2>&1 || pip3 install fb-idb > /dev/null 2>&1
COMP=$(brew --prefix)/bin/idb_companion
ls -la $COMP
sudo mkdir -p /usr/local/bin
sudo ln -sf $COMP /usr/local/bin/idb_companion
$COMP --udid $UDID > $OUT/comp.txt 2>&1 &
sleep 10
idb connect localhost 10882
SOCK=$(lsof -aUc launchd_sim 2>/dev/null | grep 'com.apple.webinspectord_sim.socket' | head -1 | awk '{print $NF}')
ios_webkit_debug_proxy -s unix:$SOCK > $OUT/iwdp.txt 2>&1 &
sleep 5
xcrun simctl launch $UDID com.munfordvillesports.app
sleep 30
node debug/listen.js arm
idb ui describe-all > $OUT/ax.json 2> $OUT/ax.err
XY=$(python3 debug/tapxy.py 'Sign In' $OUT/ax.json 2> $OUT/labels.txt)
idb ui tap $XY 2>&1 | tail -2
sleep 10
xcrun simctl io $UDID screenshot $OUT/b1.png
sips -Z 520 -s format jpeg -s formatOptions 50 $OUT/b1.png --out $OUT/b1.jpg > /dev/null
echo B64b1-START
base64 -b 100 -i $OUT/b1.jpg
echo B64b1-END
echo ===== RESULTS
tail -3 $OUT/comp.txt
head -3 $OUT/ax.err
cut -c1-700 $OUT/labels.txt
echo TAP AT $XY
node debug/listen.js read
exit 0
