#!/bin/sh -e

envs=(Dev Pre Release)
env=$1
token=$2
dingtalkToken=$3

if [[ ${env} == '' ]]
then
    env=${envs[0]}
    echo "环境参数为空，默认设置为${envs[0]}"
fi

if [[ ! "${envs[@]}" =~ "$env" ]]
then
    env=${envs[0]}
    echo "环境参数值不为${envs[@]}，默认设置为${envs[0]}"
fi

echo 上传Cocoapods开始:$(date +%Y-%m-%d\ %H:%M:%S) 

sh prepare.sh

# 压缩源码并上传至OSS
for podfile in $(find . -maxdepth 1 -name "*.podspec" | sort)
do
    # 获取文件名和版本号
    name="${podfile:2}"
    name="${name/".podspec"}"
    version=""
    while read line
    do
        if [[ ${line} == s.version* ]]
        then
            version="$(echo ${line} | tr -d '[:space:]' | tr -d \')"
            version="${version:10}"
            break
        fi
    done < ${podfile}

    logFile=build/log/${name}.txt
    # 压缩源码
    filename="${name}-${version}.zip"
    echo "压缩${name} -> ${filename} ...."
    echo "压缩文件============================" >> ${logFile}
    zip -r build/zip/${filename} ${name} -r >> ${logFile}
    echo "\n\n" >> ${logFile}

    # 上传地址
    url="https://mas-artifacts.yodo1.com/${version}/iOS/${env}/${filename}"
    echo "上传:${url}"
    echo "上传文件============================" >> ${logFile}
    ./ossutilmac64 cp build/zip/${filename} oss://yodo1-mas-sdk/${version}/iOS/${env}/ -c ~/.ossutilconfig -u

    # 修改podspec文件的s.sources
    echo "" > build/${name}.podspec
    while read line
    do
        if [[ ${line} == *:git* ]]
        then
            echo "s.source           = { :http => '${url}' }" >> build/${name}.podspec
        else
            echo "$line" >> build/${name}.podspec
        fi
    done < ${podfile}
done

# 上传Cocoapods
echo "开始上传Cocoapods..."
cocoapodsSpecs="https://github.com/CocoaPods/Specs.git,https://github.com/Yodo1Games/Yodo1Spec.git"
repositoryName="Yodo1Mas-${env}"
repositoryToken=""
privateSpecs=""
if [[ ${token} != '' ]]
then
    repositoryToken="x-access-token:${token}@"
fi

if [[ ${env} == "Release" ]]
then
    privateSpecs="https://${repositoryToken}github.com/Yodo1Games/MAS-Spec.git"
else
    privateSpecs="https://${repositoryToken}github.com/Yodo1Games/MAS-Spec-${env}.git"
fi

echo 仓库地址:${privateSpecs}

echo "上传Cocoapods============================" >> build/log/Yodo1MasCore.txt
pod repo add $repositoryName $privateSpecs
pod repo push $repositoryName build/Yodo1MasCore.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs}" >> build/log/Yodo1MasCore.txt

# 先将非Max的Mediation上传至Cocoapods
for podfile in $(find . -maxdepth 1 -name "Yodo1MasMediation*.podspec" | sort)
do
    if [[ ! ${podfile} =~ "Max.podspec" ]]
    then
        name=${podfile:2}
        logFile=build/log/${name/".podspec"}.txt
        echo 上传Cocoapods:${name}
        echo "上传Cocoapods============================" >> ${logFile}
        pod repo push $repositoryName build/$name --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> ${logFile}
    fi
done

# 将Max的Mediation上传至Cocoapods
for podfile in $(find . -maxdepth 1 -name "Yodo1MasMediation*.podspec" | sort)
do
    if [[ ${podfile} =~ "Max.podspec" ]]
    then
        name=${podfile:2}
        logFile=build/log/${name/".podspec"}.txt
        echo 上传Cocoapods:${name}
        echo "上传Cocoapods============================" >> ${logFile}
        pod repo push $repositoryName build/$name --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> ${logFile}
    fi
done

echo "上传Cocoapods============================" >> build/log/Yodo1MasCN.txt
pod repo push $repositoryName build/Yodo1MasCN.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> build/log/Yodo1MasCN.txt

echo "上传Cocoapods============================" >> build/log/Yodo1MasStandard.txt
pod repo push $repositoryName build/Yodo1MasStandard.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> build/log/Yodo1MasStandard.txt

echo "上传Cocoapods============================" >> build/log/Yodo1MasFull.txt
pod repo push $repositoryName build/Yodo1MasFull.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> build/log/Yodo1MasStandard.txt

# 发送钉钉机器人消息
if [[ ${dingtalkToken} == '' ]]
then
    echo "Token为空，无法发送钉钉机器人消息"
else
    # 获取SDK版本号
    sdkVersion=''
    while read line
    do
        if [[ ${line} == s.version* ]]
        then
            sdkVersion="$(echo ${line} | tr -d '[:space:]' | tr -d \')"
            sdkVersion="${sdkVersion:10}"
            break
        fi
    done < build/Yodo1MasFull.podspec

    msgTitle="Actions:Release iOS Yodo1MasSDK"
    msgContent="#### ${msgTitle}"
    msgContent="\n${msgContent}Result: Actions Completed"
    msgContent="\n${msgContent}Environment: ${env}"
    msgContent="\n${msgContent}Version: ${sdkVersion}"
    msgContent="\n${msgContent}#####Detail:"
    for podfile in $(find . -maxdepth 1 -name "*.podspec" | sort)
    do
        # 获取文件名和版本号
        name="${podfile:2}"
        name="${name/".podspec"}"
        version=""

        if [[ ${name} == 'Yodo1MasUnityBridge' ]]
        then
            continue
        fi

        while read line
        do
            if [[ ${line} == s.version* ]]
            then
                version="$(echo ${line} | tr -d '[:space:]' | tr -d \')"
                version="${version:10}"
                break
            fi
        done < ${podfile}

        logFile=build/log/${name}.txt
        if [ ! -d ~/.cocoapods/repos/${repositoryName}/${name}/${version}/ ]
        then
            ./ossutilmac64 cp ${logFile} oss://yodo1-mas-sdk/${version}/iOS/ -c ~/.ossutilconfig -u
            msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](https://mas-artifacts.yodo1.com/${version}/iOS/${name}.txt)"
        else
            msgContent="${msgContent}\n- ${name} 成功"
        fi
    done
    
    curl "https://oapi.dingtalk.com/robot/send?access_token=${dingtalkToken}" -H "Content-Type: application/json" -d "{\"msgtype\": \"markdown\",\"markdown\": {\"title\":\"Actions:${msgTitle}\",\"text\":\"${msgContent}\",\"at\":{\"isAtAll\":true}}}"
fi

#  修改Yodo1MasMediationFacebook
echo "修改Yodo1MasMediationFacebook.podspec ..."
name='Yodo1MasMediationFacebook'
version=''
while read line
do
    if [[ ${line} == s.version* ]]
    then
        version="$(echo ${line} | tr -d '[:space:]' | tr -d \')"
        version="${version:10}"
        break
    fi
done < build/${name}.podspec

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
