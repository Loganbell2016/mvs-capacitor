set -x
OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install
npx cap add ios
npx cap sync ios
grep -o 'loggingBehavior[^,]*' ios/App/App/capacitor.config.json
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build | tail -5
APP=/tmp/dd/Build/Products/Release-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b
xcrun simctl install $UDID $APP
for n in 1 2 3; do xcrun simctl launch $UDID com.munfordvillesports.app; sleep 30; xcrun simctl io $UDID screenshot $OUT/a$n.png; xcrun simctl terminate $UDID com.munfordvillesports.app; sleep 3; done
for n in 1 2; do xcrun simctl openurl $UDID https://www.munfordvillesports.com/app; sleep 30; xcrun simctl io $UDID screenshot $OUT/s$n.png; xcrun simctl terminate $UDID com.apple.mobilesafari; sleep 3; done
set +x
for f in a1 a2 a3 s1 s2; do sips -Z 520 -s format jpeg -s formatOptions 55 $OUT/$f.png --out $OUT/$f.jpg > /dev/null; echo B64$f-START; base64 -b 100 -i $OUT/$f.jpg; echo B64$f-END; done
exit 0
