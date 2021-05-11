#!/bin/sh -e

envs=(Dev Pre Release)
env=$1
token=$2

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

    # 压缩源码
    filename="${name}-${version}.zip"
    echo "压缩${name} -> ${filename} ...."
    zip -r build/zip/${filename} ${name} -r

    # 上传地址
    url="https://mas-artifacts.yodo1.com/${version}/iOS/${filename}"
    echo "上传:${url}"
    ./ossutilmac64 cp build/zip/${filename} oss://yodo1-mas-sdk/${version}/iOS/ -c ~/.ossutilconfig -u

    # 修改podspec文件的s.sources
    echo "" > build/${name}.podspec
    while read line
    do
        if [[ ${line} == s.source* ]]
        then
            echo "s.source           = { :http => '${url}' }" >> build/${name}.podspec
        else
            echo "$line" >> build/${name}.podspec
        fi
    done < ${podfile}
done

上传Cocoapods
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

pod repo add $repositoryName $privateSpecs
pod repo push $repositoryName build/Yodo1MasCore.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs}"

# 先将非Max的Mediation上传至Cocoapods
for podfile in $(find . -maxdepth 1 -name "Yodo1MasMediation*.podspec" | sort)
do
    if [[ ! ${podfile} =~ "Max.podspec" ]]
    then
        name=${podfile:2}
        echo 上传Cocoapods:${name}
        pod repo push $repositoryName build/$name --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}"
    fi
done

# 将Max的Mediation上传至Cocoapods
for podfile in $(find . -maxdepth 1 -name "Yodo1MasMediation*.podspec" | sort)
do
    if [[ ${podfile} =~ "Max.podspec" ]]
    then
        name=${podfile:2}
        echo 上传Cocoapods:${name}
        pod repo push $repositoryName build/$name --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}"
    fi
done

pod repo push $repositoryName build/Yodo1MasCN.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}"
pod repo push $repositoryName build/Yodo1MasStandard.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}"
pod repo push $repositoryName build/Yodo1MasFull.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}"

#  修改Yodo1MasMediationFacebook
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

cd ~/.cocoapods/repos/${repositoryName}/${name}/${version}
sed -i "" '39c\'$'\n  # s.dependency \'FBAudienceNetwork\', \'6.2.1\'\n' ${name}.podspec
sed -i "" '39a\'$'\n  s.vendored_frameworks = s.name + \'/Lib/**/*.framework\'\n' ${name}.podspec
git add ${name}.podspec
git commit -m "[Update] ${name} (${version})"
git push origin main

echo 上传Cocoapods结束:$(date +%Y-%m-%d\ %H:%M:%S) 