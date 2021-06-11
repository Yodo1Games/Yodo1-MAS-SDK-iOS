#!/bin/sh

arg1=$1

if [ ! -n "$arg1" ]; then {
	echo "input xcode .xcodeproj  path "
} else {
  PROJECT_NAME=${arg1}
  python ./apply2xcode.py  ${PROJECT_NAME}
} 
fi

workpath=`dirname $1`
infoplistPath="Info.plist"
paths=`find ${workpath} -name ${infoplistPath}`

for filePath in $paths  
do  
  always=`/usr/libexec/PlistBuddy -c 'Print :NSLocationAlwaysUsageDescription' ${filePath}`
  if [ ! -n "$always" ];then {
    /usr/libexec/PlistBuddy -c 'Add :NSLocationAlwaysUsageDescription string "Some ad content may require access to the location for an interactive ad experience."' ${filePath}
    # echo "添加 [位置访问权限] NSLocationAlwaysUsageDescription "
  }
  fi

  when=`/usr/libexec/PlistBuddy -c 'Print :NSLocationWhenInUseUsageDescription' ${filePath}`
  if [ ! -n "$when" ];then {
    /usr/libexec/PlistBuddy -c 'Add :NSLocationWhenInUseUsageDescription string "Some ad content may require access to the location for an interactive ad experience."' ${filePath}
    # echo "添加 [位置访问权限] NSLocationWhenInUseUsageDescription "
  }
  fi 
  applovin_Key=`/usr/libexec/PlistBuddy -c 'Print :AppLovinSdkKey' ${filePath}`
  if [ ! -n "$applovin_Key" ];then {
    /usr/libexec/PlistBuddy -c 'Add :AppLovinSdkKey string "xcGD2fy-GdmiZQapx_kUSy5SMKyLoXBk8RyB5u9MVv34KetGdbl4XrXvAUFy0Qg9scKyVTI0NM4i_yzdXih4XE"' ${filePath}
  }
  fi 

########## 自动添加SKAdNetworkItems ##########

sk=`/usr/libexec/PlistBuddy -c 'Print :SKAdNetworkItems' ${filePath}`
#    echo "$sk"
if [ ! -n "$sk" ];then
echo "不存在"
else
/usr/libexec/PlistBuddy -c 'Delete :SKAdNetworkItems' ${filePath}
echo "先删除，再添加！"
fi

#数组
list=("275upjj5gd.skadnetwork"
"2u9pt9hc89.skadnetwork"
"3rd42ekr43.skadnetwork"
"4468km3ulz.skadnetwork"
"44jx6755aq.skadnetwork"
"4fzdc2evr5.skadnetwork"
"4pfyvq9l8r.skadnetwork"
"5lm9lj6jb7.skadnetwork"
"6g9af3uyq4.skadnetwork"
"7rz58n8ntl.skadnetwork"
"7ug5zh24hu.skadnetwork"
"8s468mfl3y.skadnetwork"
"9nlqeag3gk.skadnetwork"
"9rd848q2bz.skadnetwork"
"9t245vhmpl.skadnetwork"
"c6k4g5qg8m.skadnetwork"
"cg4yq2srnc.skadnetwork"
"ejvt5qm6ak.skadnetwork"
"g28c52eehv.skadnetwork"
"hs6bdukanm.skadnetwork"
"klf5c3l5u5.skadnetwork"
"m8dbw4sv7c.skadnetwork"
"mlmmfzh3r3.skadnetwork"
"mtkv5xtk9e.skadnetwork"
"ppxm28t8ap.skadnetwork"
"prcb7njmu6.skadnetwork"
"rx5hdcabgc.skadnetwork"
"t38b2kh725.skadnetwork"
"tl55sbb4fm.skadnetwork"
"u679fj5vs4.skadnetwork"
"uw77j35x4d.skadnetwork"
"v72qych5uu.skadnetwork"
"yclnxrl5pm.skadnetwork"
"2fnua5tdw4.skadnetwork"
"3qcr597p9d.skadnetwork"
"3qy4746246.skadnetwork"
"3sh42y64q3.skadnetwork"
"424m5254lk.skadnetwork"
"5a6flpkh64.skadnetwork"
"av6w8kgt66.skadnetwork"
"cstr6suwn9.skadnetwork"
"e5fvkxwrpn.skadnetwork"
"ecpz2srf59.skadnetwork"
"f38h382jlk.skadnetwork"
"hjevpa356n.skadnetwork"
"k674qkevps.skadnetwork"
"kbd757ywx3.skadnetwork"
"ludvb6z3bs.skadnetwork"
"n6fk4nfna4.skadnetwork"
"p78axxw29g.skadnetwork"
"s39g8k73mm.skadnetwork"
"v9wttpbfk9.skadnetwork"
"wzmmz9fp6w.skadnetwork"
"y2ed4ez56y.skadnetwork"
"ydx93a7ass.skadnetwork"
"zq492l623r.skadnetwork"
"24t9a8vw3c.skadnetwork"
"32z4fx6l9h.skadnetwork"
"523jb4fst2.skadnetwork"
"54nzkqm89y.skadnetwork"
"578prtvx9j.skadnetwork"
"5l3tpt7t6e.skadnetwork"
"6xzpu9s2p8.skadnetwork"
"79pbpufp6p.skadnetwork"
"9b89h5y424.skadnetwork"
"cj5566h2ga.skadnetwork"
"feyaarzu9v.skadnetwork"
"ggvn48r87g.skadnetwork"
"glqzh8vgby.skadnetwork"
"gta9lk7p23.skadnetwork"
"n9x2a789qt.skadnetwork"
"pwa73g5rt2.skadnetwork"
"wg4vff78zm.skadnetwork"
"xy9t38ct57.skadnetwork"
"zmvfpc5aq8.skadnetwork"
"n38lu8286q.skadnetwork"
"252b5q8x7y.skadnetwork"
"9g2aggbj52.skadnetwork"
"dzg6xy7pwj.skadnetwork"
"f73kdq92p3.skadnetwork"
"hdw39hrw9y.skadnetwork"
"y45688jllp.skadnetwork"
"w9q455wk68.skadnetwork"
"su67r6k2v3.skadnetwork"
"737z793b9f.skadnetwork"
"r26jy69rpl.skadnetwork"
"22mmun2rn5.skadnetwork"
"238da6jt44.skadnetwork"
"44n7hlldy6.skadnetwork"
"488r3q3dtq.skadnetwork"
"52fl2v3hgk.skadnetwork"
"5tjdwbrq8w.skadnetwork"
"97r2b46745.skadnetwork"
"9yg77x724h.skadnetwork"
"gvmwg8q7h5.skadnetwork"
"mls7yz5dvl.skadnetwork"
"n66cz3y3bx.skadnetwork"
"nzq8sh4pbs.skadnetwork"
"pu4na253f3.skadnetwork"
"v79kvwwj4g.skadnetwork"
"yrqqpx2mcb.skadnetwork"
"z4gj7hsk7h.skadnetwork"
"4dzt52r2t5.skadnetwork"
"bvpn9ufa9b.skadnetwork"
"f7s53z58qe.skadnetwork"
"7953jerfzd.skadnetwork"
"lr83yxwka7.skadnetwork"
"74b6s63p6l.skadnetwork"
"8c4e2ghe7u.skadnetwork"
"v4nxqhlyqp.skadnetwork"
"x44k69ngh6.skadnetwork"
"mp6xlyr22a.skadnetwork"
"294l99pt4k.skadnetwork"
"kbmxgpxpgc.skadnetwork"
"r45fhb6rf7.skadnetwork"
"b9bk5wbcq9.skadnetwork"
"kbmxgpxpgc.skadnetwork"
"x8uqf25wch.skadnetwork"
"qqp299437r.skadnetwork"
"294l99pt4k.skadnetwork"
"rvh3l7un93.skadnetwork"
"x8jxxk4ff5.skadnetwork"
)

#按序号遍历
for i in "${!list[@]}"; do
va=${list[$i]}
/usr/libexec/PlistBuddy -c "add :SKAdNetworkItems array" -c "add :SKAdNetworkItems:$i dict" -c "add :SKAdNetworkItems:$i:SKAdNetworkIdentifier string '$va'" ${filePath}
done


done




