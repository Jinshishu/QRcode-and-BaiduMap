//
//  JSS_QRCodeViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_QRCodeViewController.h"

@interface JSS_QRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *InfoLabel;
@end

@implementation JSS_QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"create"]) {
        JSS_CreateQRCodeViewController *createVC = segue.destinationViewController;
        
        createVC.myBlock = ^(UIImage *image) {
            self.myImageView.image = image;
        };
    }
    else {
        JSS_ScanQRCodeViewController *scanVC = segue.destinationViewController;
        
        scanVC.infoBlock = ^(NSString *info) {
            self.InfoLabel.text = info;
        };
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
