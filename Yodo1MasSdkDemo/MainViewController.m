//
//  MainViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "MainViewController.h"
#import <Yodo1MasCore/Yodo1Mas.h>

@interface MainViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputField.delegate = self;
}

- (IBAction)onEnterClicked:(UIButton *)sender {
    NSString *appId = [_inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (appId == nil || appId.length == 0) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [[Yodo1Mas sharedInstance] initWithAppId:appId successful:^{
        UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DemoViewController"];
        [weakSelf showViewController:controller sender:nil];
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"初始化错误 - %@", error.localizedDescription);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onEnterClicked:self.enterButton];
    return NO;
}

@end
