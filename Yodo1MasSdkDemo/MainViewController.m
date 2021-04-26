//
//  MainViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "MainViewController.h"
#import "Yodo1Mas.h"
#import <Toast/Toast.h>

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
    self.inputField.enabled = NO;
    self.enterButton.enabled = NO;
    [self.enterButton setTitle:@"SDK init..." forState:UIControlStateNormal];
    __weak __typeof(self)weakSelf = self;
    [[Yodo1Mas sharedInstance] initWithAppId:appId successful:^{
        weakSelf.inputField.enabled = YES;
        weakSelf.enterButton.enabled = YES;
        [weakSelf.enterButton setTitle:@"Confirm" forState:UIControlStateNormal];

        UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DemoViewController"];
        [weakSelf showViewController:controller sender:nil];
    } fail:^(NSError * _Nonnull error) {
        weakSelf.inputField.enabled = YES;
        weakSelf.enterButton.enabled = YES;
        [weakSelf.enterButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [weakSelf.view makeToast:@""];
        NSLog(@"初始化错误 - %@", error.localizedDescription);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onEnterClicked:self.enterButton];
    return NO;
}

@end
