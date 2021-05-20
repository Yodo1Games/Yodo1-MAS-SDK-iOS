//
//  Yodo1LuckyWheelHelper.m
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1LuckyWheelViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <WebKit/WebKit.h>
#import "Yodo1Mas.h"
#import "Yodo1MasStorage.h"


@interface Yodo1LuckyWheelViewController ()
<WKUIDelegate,
WKNavigationDelegate,
WKScriptMessageHandler,
Yodo1MasLuckyWheelAdDelegate
>

@property(nonatomic,strong) WKWebView * webView;
@property(nonatomic,strong) WKUserContentController * userCC;
@property(nonatomic,strong) NSMutableDictionary * adInfo;
@property(nonatomic,assign) NSInteger state;
@property(nonatomic,strong) UIButton * dismissButton;
@property(nonatomic,assign) BOOL isLoadSuccess;
@property(nonatomic,copy) NSString * reward_collect_id;
@property(nonatomic,assign) BOOL isReward;
@property (nonatomic, weak) id<Yodo1MasLuckyWheelRewardDelegate> delegate;


@end

@implementation Yodo1LuckyWheelViewController

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preference = [[WKPreferences alloc]init];
        preference.minimumFontSize = 0;
        preference.javaScriptEnabled = YES;
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.navigationDelegate = self;
        _userCC = config.userContentController;
    }
    return _webView;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = self.view.bounds.size.width;
        _dismissButton.frame = CGRectMake(width - 60, 5, 40, 40);
        NSBundle * mas_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Yodo1Ads" ofType:@"bundle"]];
        NSInteger screen = (NSInteger)[UIScreen mainScreen].scale;
        NSString * name = [@"mas_close@" stringByAppendingFormat:@"%ldx",(long)screen];
        UIImage * closeImg = [UIImage imageWithContentsOfFile:[mas_bundle pathForResource:name ofType:@"png"]];
        [_dismissButton setImage:closeImg forState:UIControlStateNormal];
        [_dismissButton setImage:closeImg forState:UIControlStateSelected];
        _dismissButton.hidden = YES;
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (NSMutableDictionary *)adInfo {
    if (!_adInfo) {
        _adInfo = @{}.mutableCopy;
    }
    return _adInfo;
}

- (void)addObservers {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(adInfo:) name:@"RewardGameAdStart" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(adInfo:) name:@"RewardGameAdEnd" object:nil];
}

- (void)addAllScriptHandler {
    [self.userCC addScriptMessageHandler:self name:@"gameStart"];
    [self.userCC addScriptMessageHandler:self name:@"gameEnd"];
    [self.userCC addScriptMessageHandler:self name:@"adStart"];
    [self.userCC addScriptMessageHandler:self name:@"adEnd"];
    [self.userCC addScriptMessageHandler:self name:@"sign"];
    [self.userCC addScriptMessageHandler:self name:@"deviceInfo"];
    [self.userCC addScriptMessageHandler:self name:@"gameClose"];
}

- (void)removeAllScriptHandler {
    [self.userCC removeScriptMessageHandlerForName:@"gameStart"];
    [self.userCC removeScriptMessageHandlerForName:@"gameEnd"];
    [self.userCC removeScriptMessageHandlerForName:@"adStart"];
    [self.userCC removeScriptMessageHandlerForName:@"adEnd"];
    [self.userCC removeScriptMessageHandlerForName:@"sign"];
    [self.userCC removeScriptMessageHandlerForName:@"deviceInfo"];
    [self.userCC removeScriptMessageHandlerForName:@"gameClose"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.dismissButton];
    self.state = 0;
    [self addAllScriptHandler];
    [self addObservers];
    self.webView.frame = self.view.bounds;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:Yodo1LuckyWheelHelper.shared.webUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10]];
    
    [[Yodo1Mas sharedInstance]setLuckyWheelAdDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.dismissButton.hidden = self.isLoadSuccess;
    });
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"gameStart"]) {
        [self gameStart];
    }else if ([message.name isEqualToString:@"gameEnd"]) {
        [self gameEnd:message];
    }else if ([message.name isEqualToString:@"adStart"]) {
        [self adStart];
    }else if ([message.name isEqualToString:@"sign"]) {
        [self sign:message];
    }else if ([message.name isEqualToString:@"deviceInfo"]) {
        [self deviceInfo];
    }else if ([message.name isEqualToString:@"gameClose"]) {
        [self gameClose];
    }
}

- (void)evaluateJavaScript:(NSString *)funcStr pram:(NSDictionary *)dic handle:(void (^)(id response, NSError * error))handle {
    //转为json
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:(NSJSONWritingPrettyPrinted) error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonStr = [self noWhiteSpaceString:jsonStr];
    //给js传值，获取用户信息
    NSString *inputValueJS = [NSString stringWithFormat:@"%@('%@')", funcStr, jsonStr];
    [self.webView evaluateJavaScript:inputValueJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handle) {
            handle(response,error);
        }
    }];
}

- (NSString *)noWhiteSpaceString:(NSString *)string {
    NSString *newString = string;
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newString;
}

- (void)gameStart {
#if DEBUG
    NSString * msg = @"Start to play reward game";
    [self postMessage:msg];
#endif
}

- (void)gameEnd:(WKScriptMessage *)message {
    self.reward_collect_id = nil;
    if (self.delegate && message.body) {
        if ([message.body isKindOfClass:[NSString class]]) {
            NSString * bodyJson = message.body;
            NSDictionary * body = [NSJSONSerialization JSONObjectWithData:[bodyJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            if (body[@"reward_collect_id"] && body[@"activity_id"]) {
                __weak typeof(self) weakSelf = self;
                self.reward_collect_id = body[@"reward_collect_id"];
                [Yodo1LuckyWheelHelper.shared rewardGameReward:body
                                                      response:^(NSDictionary * _Nonnull reward) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    NSString * rewardResult = [strongSelf rewardString:reward];
                    if ([rewardResult isEqualToString:@"failed"]) {
                        NSError * error = [NSError errorWithDomain:@"com.yodo1.rewardgame" code:-7 userInfo:@{NSLocalizedDescriptionKey:@"Reward Information Request Failed."}];
                        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onDisplayFailure:)]) {
                            [strongSelf.delegate onDisplayFailure:error.localizedDescription];
                        }
                        return;
                    }
                    if (rewardResult.length) {
                        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onSuccess:)]) {
                            [strongSelf.delegate onRewardEarned:rewardResult];
                        }
                    }else{
                        NSError * error = [NSError errorWithDomain:@"com.yodo1.rewardgame" code:-6 userInfo:@{NSLocalizedDescriptionKey:@"Illegal Reward Information."}];
                        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onDisplayFailure:)]) {
                            [strongSelf.delegate onDisplayFailure:error.localizedDescription];
                        }
                    }
                }];
            }
            NSDictionary *dict = @{@"state":@(0)};
            [self evaluateJavaScript:@"gameEndResult" pram:dict handle:nil];
        }else{
            NSError * error = [NSError errorWithDomain:@"com.yodo1.rewardgame" code:-5 userInfo:@{NSLocalizedDescriptionKey:@"JSON Serialization Failed."}];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onDisplayFailure:)]) {
                [self.delegate onDisplayFailure:error.localizedDescription];
            }
            NSDictionary *dict = @{@"state":@(1)};
            [self evaluateJavaScript:@"gameEndResult" pram:dict handle:nil];
        }
    }
}

- (NSString *)rewardString:(NSDictionary *)rewardData {
    if (!rewardData) {return @"failed";}
    
    NSString * sign = rewardData[@"sign"];
    NSDictionary * reward = rewardData[@"reward"];
    NSString * code = reward[@"code"];
    NSString * count = reward[@"count"];
    NSString * sign_check = [Yodo1LuckyWheelHelper.shared signMd5String:[NSString stringWithFormat:@"%@%@%@%@",self.reward_collect_id,code,count,@"7vJvQSZbcMTggaay2pD47l5l"]];
    if ([sign_check isEqualToString:sign]) {
        return [Yodo1LuckyWheelHelper.shared stringWithJSONObject:reward error:nil];
    }
    return @"";
}

- (void)adInfo:(NSNotification *)noti {
    [self.adInfo removeAllObjects];
    if (noti.userInfo.count) {
        [self.adInfo addEntriesFromDictionary:noti.userInfo];
    }
    self.adInfo[@"state"] = @(self.state);
    if ([noti.name isEqualToString:@"RewardGameAdStart"]) {
        [self evaluateJavaScript:@"adStartResult" pram:self.adInfo handle:nil];
    }else if ([noti.name isEqualToString:@"RewardGameAdEnd"]) {
        [self evaluateJavaScript:@"adEndResult" pram:self.adInfo handle:nil];
    }
}

- (void)adStart {
    // state 0正常 1失败
    self.state = 1;
    self.isReward = false;
    if ([Yodo1Mas.sharedInstance isRewardAdLoaded]) {
        [Yodo1Mas.sharedInstance showRewardAdWithPlacement:@"mas_lucky_wheel"];
    } else {
        [self.adInfo removeAllObjects];
        self.adInfo[@"state"] = @(self.state);
        [self evaluateJavaScript:@"adStartResult" pram:self.adInfo handle:nil];
    }
    //测试使用
#if DEBUG
    NSString * msg = @"Start to play Ads";
    [self postMessage:msg];
#endif
}
#if DEBUG
- (void)postMessage:(NSString *)msg {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RewardGame" object:nil userInfo:@{@"desc":msg}];
}
#endif
- (void)adEnd:(BOOL)success {
    // 0 播放成功 1 播放失败
    self.state = success ? 0 : 1;
#if DEBUG
    NSString * msg = @"End of play Ads.";
    [self postMessage:msg];
#endif
}

- (void)sign:(WKScriptMessage *)message {
    NSString * device_id = Yodo1MasStorage.keychainDeviceId;
    NSString * ts = [NSString stringWithFormat:@"%lu", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    NSString * sign = [NSString stringWithFormat:@"%@%@%@%@",Yodo1LuckyWheelHelper.shared.appKey,device_id,ts,@"7vJvQSZbcMTggaay2pD47l5l"];
    sign = [Yodo1LuckyWheelHelper.shared signMd5String:sign];
    NSMutableDictionary * dict = @{@"sign":sign,@"timestamp":ts}.mutableCopy;
    if (message.body && [message.body isKindOfClass:[NSString class]]) {
        NSString * jsonStr = message.body;
        NSDictionary * body = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (body.count) {
            [dict addEntriesFromDictionary:body];
        }
    }
    [self evaluateJavaScript:@"signResult" pram:dict handle:nil];
}

- (void)deviceInfo {
    NSString * ori = @"portrait";
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        ori = @"landscape";
    }
    NSString * model = @"iphone";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        model = @"ipad";
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString * os_version = [[UIDevice currentDevice] systemVersion];
    NSDictionary* dict = @{@"os":@"ios",@"os_version":os_version,@"sdk_version":@"",
                           @"device_model":model,@"appkey":Yodo1LuckyWheelHelper.shared.appKey,@"device_id":Yodo1MasStorage.keychainDeviceId,
                           @"device_orientation":ori,@"language":Yodo1LuckyWheelHelper.shared.language,
                           @"width":@(screenSize.width),@"height":@(screenSize.height),
                           @"debug":@(YES)};
    [self evaluateJavaScript:@"deviceInfoResult" pram:dict handle:nil];
}

- (void)gameClose {
    [self removeAllScriptHandler];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.dismissButton.hidden = YES;
    self.isLoadSuccess = YES;
    [self deviceInfo];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isLoadSuccess = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDisplayFailure:)]) {
        [self.delegate onDisplayFailure:error.localizedDescription];
    }
}

+ (void)show:(UIViewController *)viewController
    delegate:(id<Yodo1MasLuckyWheelRewardDelegate>)delegate {
    Yodo1LuckyWheelViewController * lw = [[self class] new];
    lw.delegate = delegate;
    lw.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:lw animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    [self adEnd:self.isReward];
    [NSNotificationCenter.defaultCenter postNotificationName:@"RewardGameAdEnd" object:nil];
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    self.isReward = false;
}

- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    self.isReward = true;
}

@end
