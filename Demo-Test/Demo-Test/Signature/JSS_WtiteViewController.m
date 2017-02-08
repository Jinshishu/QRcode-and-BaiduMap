//
//  JSS_WtiteViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_WtiteViewController.h"
#import "JSS_WriteView.h"

static void *xxcontext = &xxcontext;

@interface JSS_WtiteViewController ()

@property (weak, nonatomic) IBOutlet JSS_WriteView *writeView;

@property (strong, nonatomic) UIImage *img;

@end

@implementation JSS_WtiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //注册KVO
    [self.writeView addObserver:self forKeyPath:@"pointArray" options:NSKeyValueObservingOptionNew context:xxcontext];
}

- (void)dealloc {
    [self.writeView removeObserver:self forKeyPath:@"pointArray"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == xxcontext) {
        if ([keyPath isEqualToString:@"pointArray"]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        }
        else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)saveAction{
    self.img = [self saveView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)saveView {
    
    UIView *screenView = self.writeView;
    UIGraphicsBeginImageContext(screenView.bounds.size);
    [screenView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"截屏成功");
    return image;
}

- (IBAction)clearAction:(UIButton *)sender {
    [self.writeView clearView];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.imageBlock != nil) {
        self.imageBlock(self.img);
    };
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
