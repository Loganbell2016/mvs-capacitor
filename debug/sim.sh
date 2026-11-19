OUT=$CM_BUILD_DIR/out
mkdir -p $OUT
npm install > /dev/null 2>&1
npx cap add ios > /dev/null 2>&1
npx cap sync ios > /dev/null 2>&1
cat ios-patch/MVSPatch.swift >> ios/App/App/AppDelegate.swift
sed -i '' 's/customClass="CAPBridgeViewController" customModule="Capacitor"/customClass="MVSViewController" customModule="App" customModuleProvider="target"/' ios/App/App/Base.lproj/Main.storyboard
PATCHCHECK=$(grep -c MVSViewController ios/App/App/Base.lproj/Main.storyboard ios/App/App/AppDelegate.swift | tr '\n' ' ')
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -sdk iphonesimulator -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build 2>&1 | grep -E 'error:|BUILD' | head -10
APP=/tmp/dd/Build/Products/Release-iphonesimulator/App.app
UDID=$(xcrun simctl list devices available | grep -m1 'iPhone' | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcrun simctl bootstatus $UDID -b > /dev/null
xcrun simctl install $UDID $APP
SUMMARY=''
FIXES=(x none none resize reload load)
for n in 1 2 3 4 5; do
F=${FIXES[$n]}; [ "$F" = none ] && F=""
SIMCTL_CHILD_MVS_FIX="$F" xcrun simctl launch --stderr=$OUT/err$n.txt $UDID com.munfordvillesports.app > /dev/null
sleep 20
xcrun simctl io $UDID screenshot $OUT/l$n.png > /dev/null 2>&1
sips -Z 360 -s format jpeg -s formatOptions 45 $OUT/l$n.png --out $OUT/l$n.jpg > /dev/null
FR=$(xcrun simctl spawn $UDID log show --last 22s --style compact --predicate 'subsystem == "com.apple.WebKit"' 2>/dev/null | grep -oE 'LayerTree: [A-Za-z]+[^(]{0,80}\(reason=[0-9]+' | sed -E 's/LayerTree: ([A-Za-z]+)[^(]*[(]reason=([0-9]+)/\1:\2/' | tr '\n' ' ')
SUMMARY="$SUMMARY | L$n bytes=$(wc -c < $OUT/l$n.jpg) $FR"
xcrun simctl terminate $UDID com.munfordvillesports.app
sleep 3
done
for n in 1 2 3 4 5; do echo B64l$n-START; base64 -b 100 -i $OUT/l$n.jpg; echo B64l$n-END; done
echo ===== RESULTS
echo PATCH $PATCHCHECK
echo $SUMMARY
echo "--- MVSLOG file"; cat "$(xcrun simctl get_app_container $UDID com.munfordvillesports.app data)/Documents/mvs.log" | cut -c1-900
exit 0
