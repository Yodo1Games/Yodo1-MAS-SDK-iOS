//
//  MockViewController.m
//  Yodo1MasSdkDemo
//
//  Created by 周玉震 on 2020/12/31.
//

#import "MockViewController.h"
#import <Masonry/Masonry.h>

@interface MockViewController ()<UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString*> *> *items;

@end

@implementation MockViewController

- (instancetype)initWithSourceView:(UIView *)view {
    self = [super init];
    if (self) {
        self.preferredContentSize = CGSizeMake(300, 400);
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.sourceView = view;
        self.popoverPresentationController.sourceRect = view.bounds;
        self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        self.popoverPresentationController.delegate = self;
        
        _items = @[
            @{@"title" : @"Server Config",                  @"api" : @""},
            @{@"title" : @"Mock AppLovin Mediation Banner", @"api" : @"https://run.mocky.io/v3/d0ec4c98-c784-4995-85b5-d37251ac588f/"},
            @{@"title" : @"Mock AdMob Network Banner",      @"api" : @"https://run.mocky.io/v3/b0a66eb2-edbe-4fc1-94d1-dbd7a157ac22/"},
            @{@"title" : @"Mock AppLovin Mediation",        @"api" : @"https://run.mocky.io/v3/0a999653-141c-4eac-8447-07605465abf0/"},
            @{@"title" : @"Mock AdMob Network",             @"api" : @"https://run.mocky.io/v3/f1156264-7747-47d2-82b7-11ad4b97d117/"},
            @{@"title" : @"Mock IronSource Network",        @"api" : @"https://run.mocky.io/v3/aa45cf17-b602-4a7b-b309-5a3319d691fd/"},
            @{@"title" : @"Mock Facebook Network",          @"api" : @"https://run.mocky.io/v3/6c737c47-6797-44a5-913d-b6f165949644/"},
            @{@"title" : @"Mock Tapjoy Network",            @"api" : @"https://run.mocky.io/v3/81f600a7-0210-411a-a138-45df076dfe99/"},
            @{@"title" : @"Mock UnityAds Network",          @"api" : @"https://run.mocky.io/v3/9a1c9ad4-22cd-4bff-907a-295a3bc0e019/"},
            @{@"title" : @"Mock Vungle Network",            @"api" : @"https://run.mocky.io/v3/aae65942-c389-4cbe-a33c-4417ebe0995e/"}
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Identifier:";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary<NSString *, NSString*> *item = _items[indexPath.row];
    cell.textLabel.text = item[@"title"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary<NSString *, NSString*> *item = _items[indexPath.row];
    NSString *api = item[@"api"];
    if (api != nil && api.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:api forKey:@"MockApi"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MockApi"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onMockSelected:)]) {
        [self.delegate onMockSelected:indexPath.row];
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

@end
