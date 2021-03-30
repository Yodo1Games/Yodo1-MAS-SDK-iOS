#!/bin/zsh

rm -f *.ipa

CURRENTPATH=$(cd "$(dirname "$0")"; pwd)
cd ..

BUILDNUMBER=$1
BUNDLEIDENTIFIER=$2
VERSION=$3
APPKEY=$4
ADMOBID=$5
REPOUPDATE=$6
UPLOADOTA="Y"

if [ "${REPOUPDATE}" == "Y" ];then
	pod install --repo-update
else
	pod install
fi

TARGETNAME="Yodo1MasSdkDemo"
WORKSPACE="Yodo1MasSdkDemo.xcworkspace"
INFOPLIST=${CURRENTPATH}/../Yodo1MasSdkDemo/Info.plist

if [ -n ${VERSION} ]; then
	/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${VERSION}" ${INFOPLIST}
fi

if [ -n ${APPKEY} ]; then
	/usr/libexec/PlistBuddy -c "Set Yodo1MasAppkey ${APPKEY}" ${INFOPLIST}
fi

if [ -n ${ADMOBID} ]; then
	/usr/libexec/PlistBuddy -c "Set GADApplicationIdentifier ${ADMOBID}" ${INFOPLIST}
fi

echo "Clean scheme ..."
xcodebuild clean -workspace  ${WORKSPACE} -scheme ${TARGETNAME} -configuration Release -quiet

echo "Build archive ..."

FILENAME="Rivendell_"${VERSION}"_"${BUILDNUMBER}.ipa

CODESIGNIDENTITY="Apple Development: Peng Yan (6KL48W8ZBA)"
PROVISIONINGPROFILE="mas_ads_demo"

EXPORTOPTIONSPLIST=${CURRENTPATH}/ExportOptions.plist
EXPORTOPATH=${CURRENTPATH}/archive_ipa

if [ ! -f "${EXPORTOPTIONSPLIST}" ];then
    echo "ipa export options plist is not exist: <"${CURRENTPATH}/ExportOptions.plist">"
    exit 0
fi

xcodebuild archive -workspace ${WORKSPACE} -scheme ${TARGETNAME} -configuration Release -archivePath ./${TARGETNAME} -sdk iphoneos CODE_SIGN_IDENTITY="${CODESIGNIDENTITY}" PROVISIONING_PROFILE="${PROVISIONINGPROFILE}"
echo "Build archive completed ..."

echo "Export archive ..."
xcodebuild -exportArchive -exportOptionsPlist ${EXPORTOPTIONSPLIST} -archivePath ${TARGETNAME}.xcarchive -exportPath  ${EXPORTOPATH}

echo "Export archive completed ..."
echo "Resign ipa ..."

RESIGNSH=resign.sh
RESIGNSHPATH=${CURRENTPATH}/Yodo1Resign
mv ${CURRENTPATH}/archive_ipa/${TARGETNAME}.ipa  ${RESIGNSHPATH}/${FILENAME}

rm -rf ${TARGETNAME}.xcarchive
rm -rf ${EXPORTOPATH}

cd ${RESIGNSHPATH}

if [ -n ${BUNDLEIDENTIFIER} ]; then
	sh ${RESIGNSH} ${FILENAME} ${BUNDLEIDENTIFIER}
else
	sh ${RESIGNSH} ${FILENAME} 
fi

if [ -f "resign_${FILENAME}" ];then
    mv resign_${FILENAME} ../${FILENAME}
fi
rm -f *.ipa

cd ..
if [ "${UPLOADOTA}" == "Y" ];then
	echo "Export ipa success ..."
    echo "Upload to OTA ..."
    sh ${CURRENTPATH}/upload.sh ${FILENAME}
fi
