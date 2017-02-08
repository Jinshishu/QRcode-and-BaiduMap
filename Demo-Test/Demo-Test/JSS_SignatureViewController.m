//
//  JSS_SignatureViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_SignatureViewController.h"
#import "JSS_WtiteViewController.h"

@interface JSS_SignatureViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signatureButton;

@end

@implementation JSS_SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签名";
    
    //设置边距
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    JSS_WtiteViewController *wVC = segue.destinationViewController;
    wVC.imageBlock = ^(UIImage *image) {
        [self.signatureButton setBackgroundImage:image forState:UIControlStateNormal];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
