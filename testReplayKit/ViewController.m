//
//  ViewController.m
//  testReplayKit
//
//  Created by 云中追月 on 2023/4/17.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
@interface ViewController ()
@property (nonatomic, strong) RPSystemBroadcastPickerView*broadPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    _broadPickerView.preferredExtension = @""; // 此处填写你创建的Broadcast Upload Extension 的Bundle id（不是SetupUI的那个）
    [self.view addSubview:_broadPickerView];

}


@end
