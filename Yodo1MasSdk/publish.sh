#!/bin/sh -e

branch=$1
token=$2
dingtalkToken=$3

# 读取配置文件
version=""
suffix=""
env=""
while read line
do
    if [[ ${line} == *version* ]]
    then
        version="${line:8}"
    elif [[ ${line} == *suffix* ]]
    then
        suffix="${line:7}"
    elif [[ ${line} == *env* ]]
    then
        env="${line:4}"
    fi
done < config.txt

if [[ ${branch} == *master* ]]
then
    env='Release'
else
    if [[ ${env} == 'Release' ]]
    then
        env='dev'
    fi
    version="${version}-${suffix}"
fi

echo 上传Cocoapods开始:$(date +%Y-%m-%d\ %H:%M:%S) 

# 上传Cocoapods
cd Yodo1MasSdk
sh prepare.sh

sh publish-one.sh ${env} Yodo1MasCore ${version} '' ${token}

for module in $(find . -maxdepth 1 -name "Yodo1MasMediation*" | sort)
do
    name="${module:2}"
    echo ${name}
    sh publish-one.sh ${env} ${name} ${version} '' ${token}
done

for module in $(find . -maxdepth 1 -name "Yodo1MasMediation*" | sort)
do
    name="${module:2}"
    sh publish-one.sh ${env} ${name} ${version} 'Max' ${token}
done
sh publish-one.sh ${env} Yodo1MasCN ${version} '' ${token}
sh publish-one.sh ${env} Yodo1MasStandard ${version} '' ${token}
sh publish-one.sh ${env} Yodo1MasFull ${version} '' ${token}

repositoryName="Yodo1Mas-${env}"
# 验证上传Cocoapods是否成功
successful=true
msgTitle="Actions:Release iOS Yodo1MasSDK"
msgContent="#### ${msgTitle}\nResult: Actions Completed\nEnvironment: ${env}\nVersion: ${version}\n##### Detail"
for podfile in $(find build -maxdepth 1 -name "*.podspec" | sort)
do
    # 获取文件名和版本号
    name="${podfile:6}"
    name="${name/".podspec"}"

    if [[ ${name} == 'Yodo1MasUnityBridge' ]]
    then
        continue
    fi

    logFile=build/log/${name}.txt
    if [ ! -d ~/.cocoapods/repos/${repositoryName}/${name}/${version}/ ]
    then
        ./ossutilmac64 cp ${logFile} oss://yodo1-mas-sdk/${version}/iOS/ -c ~/.ossutilconfig -u
        msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](https://mas-artifacts.yodo1.com/${version}/iOS/${name}.txt)"
        successful=false
    else
        msgContent="${msgContent}\n- ${name} 成功"
    fi
done
echo "{\"successful\" : \"${successful}\", \"version\" : \"${version}\" }" > Yodo1Mas.json

#  修改Yodo1MasMediationFacebook
echo "修改Yodo1MasMediationFacebook.podspec ..."
name='Yodo1MasMediationFacebook'
cd ~/.cocoapods/repos/${repositoryName}

echo "" > ${name}/${version}/${name}.podspec.temp
while read line
do
    if [[ ${line} == *FBAudienceNetwork* ]]
    then
        echo "# s.dependency 'FBAudienceNetwork', '6.5.0'" >> ${name}/${version}/${name}.podspec.temp
        echo "s.vendored_frameworks = s.name + '/Lib/**/*.framework'" >> ${name}/${version}/${name}.podspec.temp
    else
        echo "$line" >> ${name}/${version}/${name}.podspec.temp
    fi
done < ${name}/${version}/${name}.podspec
mv ${name}/${version}/${name}.podspec.temp ${name}/${version}/${name}.podspec

originName="main"
if [[ ${env} == Dev ]]
then
   originName="master"
fi

git add .
git commit -m "[Fix] ${name} (${version})"
git push -u origin ${originName}

echo 上传Cocoapods结束:$(date +%Y-%m-%d\ %H:%M:%S) 


# 发送钉钉机器人消息
if [[ ${dingtalkToken} == '' ]]
then
    echo "Token为空，无法发送钉钉机器人消息"
else
    curl "https://oapi.dingtalk.com/robot/send?access_token=${dingtalkToken}" -H "Content-Type: application/json" -d "{\"msgtype\": \"markdown\",\"markdown\": {\"title\":\"Actions:${msgTitle}\",\"text\":\"${msgContent}\",\"at\":{\"isAtAll\":true}}}"
fi

if [[ ${successful} == true ]]
then
    exit 0
else
    exit 1
fi