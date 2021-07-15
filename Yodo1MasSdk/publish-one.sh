env=$1
name=$2
version=$3
max=$4
token=$5

echo "参数:{env:${env}, name:${name}, version:${version}, max:${max}}"

envs=(Dev Pre Release)
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

if [[ ${name} == '' ]]
then
    echo "name不能为空"
    exit 0
fi

if [[ ${version} == '' ]]
then
    echo "version不能为空"
    exit 0
fi

if [[ ${max} == 'Max' ]]
then
    if [ ! -d "${name}/${name}${max}" ]
    then
        echo "Max为空，跳过上传"
        exit 0
    fi
fi

logFile=build/log/${name}${max}.txt
filename="${name}${max}-${version}.zip"
dir="${name}${max}"
echo "压缩${name}${max} -> ${filename} ...."
echo "压缩文件============================" >> ${logFile}
cd ${name}

# 修改plist文件
plist=${name:8}
if [[ ${plist} == *Mediation* ]]
then
    plist=${plist:9}
fi
assets="${dir}/Assets/Yodo1Mas${plist}.plist"
if [ -d ${assets} ]
then
    cpAsset="${dir}/Assets/Yodo1Mas${plist}.plist.temp"
    echo "" > ${cpAsset}
    isVersion=false
    while read line
    do
        if [[ ${isVersion} == true && ${line} == \<string\>*.*.*\</string\> ]]
        then
            echo "<string>${version}</string>" >> ${cpAsset}
        else
            echo ${line} >> ${cpAsset}
        fi
        if [[ ${line} == \<key\>version\</key\> ]]
        then
            isVersion=true
        fi
    done < ${assets}
    mv -f ${cpAsset} ${assets}
fi
assets="${dir}/Assets/yodo1mas.plist"
if [ -d ${assets} ]
then
    cpAsset="${dir}/Assets/yodo1mas.plist.temp"
    echo "" > ${cpAsset}
    isVersion=false
    while read line
    do
        if [[ ${isVersion} == true && ${line} == \<string\>*.*.*\</string\> ]]
        then
            echo "<string>${version}</string>" >> ${cpAsset}
        else
            echo ${line} >> ${cpAsset}
        fi
        if [[ ${line} == \<key\>sdkVersion\</key\> ]]
        then
            isVersion=true
        fi
    done < ${assets}
    mv -f ${cpAsset} ${assets}
fi


zip -r ${filename} ${dir} LICENSE >> ./../${logFile}
cp ${filename} ./../build/zip/${filename}
rm ${filename}
cd ./../
echo "\n\n" >> ${logFile}

# 上传地址
url="https://mas-artifacts.yodo1.com/${version}/iOS/${env}/${filename}"
echo "上传:${url}"
echo "上传文件============================" >> ${logFile}
./ossutilmac64 cp build/zip/${filename} oss://yodo1-mas-sdk/${version}/iOS/${env}/ -c ~/.ossutilconfig -u

# 修改podspec文件的s.sources及版本号，并输出到build文件夹中
cpPodspec="build/${name}${max}.podspec"
echo "" > ${cpPodspec}
while read line
do
    
    if [[ ${line} == *:git* ]]
    then
        
        echo "s.source = { :http => '${url}' }" >> ${cpPodspec}
    elif [[ ${line} == *s.version*=* ]]
    then
        echo "s.version = '${version}'" >> ${cpPodspec}
    elif [[ ${line} == *s.dependency* && ${line} == *Yodo1Mas* ]]
    then
        arr=(${line//,/})
        echo "${arr[0]} ${arr[1]}, '${version}'" >> ${cpPodspec}
    else
        echo ${line} >> ${cpPodspec}
    fi
done < ${name}/${name}${max}.podspec


# 上传Cocoapods
echo "开始上传Cocoapods..."
cocoapodsSpecs="https://cdn.cocoapods.org/,https://github.com/Yodo1Games/Yodo1Spec.git" #https://github.com/CocoaPods/Specs.git,
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

echo 上传Cocoapods:${name}${max}
echo "上传Cocoapods============================" >> ${logFile}
if [ ! -d ~/.cocoapods/repos/${repositoryName} ]
then
  pod repo add ${repositoryName} ${privateSpecs}
fi
#pod repo update
echo "pod repo push ${repositoryName} build/${name}${max}.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> ${logFile}"
pod repo push ${repositoryName} build/${name}${max}.podspec --verbose --use-libraries --allow-warnings --sources="${cocoapodsSpecs},${privateSpecs}" >> ${logFile}