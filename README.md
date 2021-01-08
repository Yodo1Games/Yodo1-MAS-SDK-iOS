# Yodo1Mas

### 使用`Cocoapods`安装

终端内，执行以下命令：

```shell
cd 你项目的根目录
touch Podfile
```

使用文本编辑器打开`Podfile`， 将以下内容添加到文件内并保存‘

```ruby
source 'https://github.com/Yodo1Games/MAS-Spec.git'
pod 'Yodo1MasSDK', '~> 0.0.0.1-beta'
```

终端内，执行以下命令

```shell
cd 你项目的根目录
pod install
```

打开`.xcworkspace`文件

### 项目配置
`Info.plist`中添加
```xml

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AppLovinSdkKey</key>
	<string>xcGD2fy-GdmiZQapx_kUSy5SMKyLoXBk8RyB5u9MVv34KetGdbl4XrXvAUFy0Qg9scKyVTI0NM4i_yzdXih4XE</string>
</dict>
<dict>
	<key>GADApplicationIdentifier</key>
	<string>ca-app-pub-7188592076082444~9912617145</string>
</dict>
<array>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>cstr6suwn9.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>4DZT52R2T5.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>SU67R6K2V3.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>4PFYVQ9L8R.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>ludvb6z3bs.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>KBD757YWX3.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>F38H382JLK.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>4FZDC2EVR5.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>2U9PT9HC89.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>WZMMZ9FP6W.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>t38b2kh725.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>9T245VHMPL.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>7UG5ZH24HU.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>M8DBW4SV7C.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>mlmmfzh3r3.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>TL55SBB4FM.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>YCLNXRL5PM.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>hs6bdukanm.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>av6w8kgt66.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>8s468mfl3y.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>prcb7njmu6.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>4468km3ulz.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>9RD848Q2BZ.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>GTA9LK7P23.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>YDX93A7ASS.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>3RD42EKR43.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>bvpn9ufa9b.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>ECPZ2SRF59.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>238da6jt44.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>22mmun2rn5.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>wg4vff78zm.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>737z793b9f.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>44jx6755aq.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>W9Q455WK68.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>GLQZH8VGBY.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>c6k4g5qg8m.skadnetwork</string>
	</dict>
	<dict>
		<key>SKAdNetworkIdentifier</key>
		<string>6xzpu9s2p8.skadnetwork</string>
	</dict>
</array>
</plist>


```

## 初始化
```objc
#import <Yodo1MasCore/Yodo1Mas.h>
[[Yodo1Mas sharedInstance] initWithAppId:@"你的AppId" successful:^{
    
} fail:^(NSError * _Nonnull error) {
    
}];
```

## 使用
```objc
[Yodo1Mas sharedInstance].rewardAdDelegate = self; // 设置激励广告代理
[Yodo1Mas sharedInstance].interstitialAdDelegate = self; // 设置插屏广告代理
[Yodo1Mas sharedInstance].bannerAdDelegate = self; // 设置横幅广告代理


// 显示激励广告
[[Yodo1Mas sharedInstance] showRewardAd];
// 显示插屏广告
[[Yodo1Mas sharedInstance] showInterstitialAd];
// 显示横幅广告
[[Yodo1Mas sharedInstance] showBannerAd];


#pragma mark - Yodo1MasAdDelegate
- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdvertError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    
}

#pragma mark - Yodo1MasRewardAdDelegate
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    
}

```

## 隐私设置
```objc

// GDPR YES用户同意 NO用户拒绝
[Yodo1Mas sharedInstance].isGDPRUserConsent = YES;

// COPPA YES年龄限制 NO年龄未限制
[Yodo1Mas sharedInstance].isCOPPAAgeRestricted = NO;

// CCPA YES拒绝获取隐私数据 NO同意获取隐私数据
[Yodo1Mas sharedInstance].isCCPADoNotSell = NO;
```

## 作者

ZhouYuzhen, zhouyuzhen@yodo1.com

## License

Yodo1Mas is available under the MIT license. See the LICENSE file for more info.
