#!/bin/zsh

CURRENTPATH=$(cd "$(dirname "$0")"; pwd)
FILENAME=$1
UPLOAD_URL=https://ota.yodo1.com/api/apps
OTA_LOG=ota_upload.log
#OBB_LOG=obb_upload.log
OTA_TEAM_ID="5f28e3e406c7b00023b46506"
OTA_TOKEN="b213fc288ac56b7939987887e4c354d7"
PUBLISH_APP=${CURRENTPATH}/${FILENAME}

echo $PUBLISH_APP
if [ ! -f "${PUBLISH_APP}" ];then
    echo "App is not exist. <"${PUBLISH_APP}">"
    exit 0
fi

curl --progress-bar -o "${OTA_LOG}" -X POST "${UPLOAD_URL}/${OTA_TEAM_ID}/upload" -H "accept: application/json" -H "apiKey: ${OTA_TOKEN}" -H "content-type: multipart/form-data" -F "file=@${PUBLISH_APP};type=application/vnd.iphone"

echo "Upload to OTA completed ..."
