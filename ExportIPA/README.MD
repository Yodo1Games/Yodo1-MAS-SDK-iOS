# 自动打包脚本

`version 1.0.0`

## 环境相关
1. 需要Mac环境
2. 安装Xcode 12.x（Mac AppStore搜索Xcode）
3. 安装Cocoapods (sudo gem install -n /usr/local/bin cocoapods，该命令既可以安装也可以更新pod版本)，cocoapods版本需要1.10.x以上，使用 pod --version查看版本

## 证书相关

1. 进入 **Certificate** 目录, 双击 `EnterpriseCert_Yodo1LTD.p12` 文件, 导入密码是 `123`. 将企业签名需要的证书导入到本机的钥匙串中. 
2. 进入 **Certificate** 目录, 双击 `AppleDevelopment.p12` 文件, 导入密码是 `123`. 将打包需要的证书导入到本机的钥匙串中. 
3. 进入 **Certificate** 目录, 双击 `mas_ads_demo.mobileprovision` 文件. 将打包需要的描述文件添加到xcode可识别的文件目录.
4. 以上步骤只需要执行一次即可.

## 文件说明

1. **Certificate** 目录，存放打包需要用到的企业证书、开发者证书和描述文件
2. **Yodo1Resign**目录，存放ipa重签名脚本
3. **ExportOptions.plist**文件，ipa导出时的配置文件
4. **ipa.sh**文件，打包主脚本文件
5. **upload.sh**文件，上传ipa文件到Yodo1Flight的脚本文件
6. **ota_upload.log**文件，上传时输出的log，每次覆盖

## 脚本使用方法
首先进入到ipa.sh文件所在文件夹，然后执行：
```
sh ipa.sh <build number> <bundle identifier> <version> <appkey> <admob id> <reop update("Y" or "N")>
```
