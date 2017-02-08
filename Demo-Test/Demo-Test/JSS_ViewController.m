//
//  JSS_ViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/13.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface JSS_ViewController ()<BMKGeneralDelegate>

@end

@implementation JSS_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    //创建百度地图主引擎类对象
    BMKMapManager *manager = [[BMKMapManager alloc]init];
    //启动引擎
    [manager start:@"bOyS4fAGvZZCOp3cdHVlZt51BQ7kGNVH" generalDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
