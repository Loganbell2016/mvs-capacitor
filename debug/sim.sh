set -x
OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install
npx cap add ios
npx cap sync ios
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build | tail -5
APP=/tmp/dd/Build/Products/Release-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b
xcrun simctl install $UDID $APP
set +x
for n in 1 2; do xcrun simctl launch $UDID com.munfordvillesports.app; sleep 30; xcrun simctl io $UDID screenshot $OUT/a$n.png; for p in $(pgrep -f 'WebKit.WebContent'); do echo SAMPLE-$n-PID-$p; sample $p 2 -mayDie 2>/dev/null | sed -n '/com.apple.main-thread/,/^ *[0-9]* Thread_/p' | cut -c1-200 | head -70; done; xcrun simctl terminate $UDID com.munfordvillesports.app; sleep 3; done
for f in a1 a2; do sips -Z 520 -s format jpeg -s formatOptions 55 $OUT/$f.png --out $OUT/$f.jpg > /dev/null; echo B64$f-START; base64 -b 100 -i $OUT/$f.jpg; echo B64$f-END; done
exit 0
