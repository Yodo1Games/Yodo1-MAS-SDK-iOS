
arg1=$1
BUNDLEIDENTIFIER=$2

if [ ! -n "$arg1" ]; then
	IPANAME=$(find '.' -name "*.ipa")
else
	IPANAME=${arg1}	
fi


if [ ! -n ${IPANAME} ]; then
	echo "please raw ipa name"
	exit 0
fi

echo "-- IAP: "${IPANAME}
echo ' '

# Fix 8.1.3 BY WangLongbo 
################################################################################################
# Create an entitlements file
# parse provision profile
security cms -D -i "embedded.mobileprovision" > Temp.plist 2>&1

sed '1d' Temp.plist > ProvisionProfile.plist

# generate entitilements.plist
/usr/libexec/PlistBuddy -x -c "print:Entitlements" ProvisionProfile.plist > entitlements.plist 2>&1
# ################################################################################################


unzip ${IPANAME}


# Fix 2020/3/28 by EricHu"
APPNAME=$(find ./Payload -name "*.app")
echo "-- App "${APPNAME}

if [ -n ${BUNDLEIDENTIFIER} ]; then
	echo "-- Bundle Identifier: ${BUNDLEIDENTIFIER}"
	INFOPLIST=${APPNAME}/Info.plist
	/usr/libexec/PlistBuddy -c "set CFBundleIdentifier ${BUNDLEIDENTIFIER}" ${INFOPLIST}
fi

echo ' '
echo '-- resign Frameworks --'
echo ' '

# 对项目内的类库进行签名
# find ${APPNAME}/Frameworks -name "*.framework" -exec echo '-- framework: ' {} \;
# find ${APPNAME}/Frameworks -name "*.framework" -exec rm -rf {}/_CodeSignature/ \;
find ${APPNAME}/Frameworks -name "*.framework" -exec codesign -fs "iPhone Distribution: Yodo1 LTD" --entitlements entitlements.plist {} \;

echo ' '
echo '-- resign APP --'
echo ' '

# 对APP整体进行签名
cp ./embedded.mobileprovision ${APPNAME}/embedded.mobileprovision
# rm -rf ${APPNAME}/_CodeSignature/
codesign -fs "iPhone Distribution: Yodo1 LTD" --entitlements entitlements.plist ${APPNAME}

RE_APP=${IPANAME#*/}
echo ' '
echo '-- zip IPA -> '${RE_APP}
echo ' '

zip  -y -r resign_${RE_APP} Payload/

# 清理文件夹
rm -rf Payload/
rm Temp.plist
rm ProvisionProfile.plist
rm entitlements.plist 

rm -rf __MACOSX*
rm -rf MessagesApplicationExtensionSupport

echo ' '
echo '-- Finish --'
echo ' '





