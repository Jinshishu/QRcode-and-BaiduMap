//
//  JSS_TakePhotoViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_TakePhotoViewController.h"

#define kScreenWidth [[UIScreen mainScreen]bounds].size.width


@interface JSS_TakePhotoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (strong, nonatomic) NSMutableArray *imageArray;

@end

@implementation JSS_TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"图片展示";
    
    //设置边距
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.imageArray = [NSMutableArray array];
    [self.imageArray addObject:[UIImage imageNamed:@"add.jpg"]];
    
    [self getImage];
}

- (void)getImage{
    int row = [self.imageArray count] % 4 == 0 ? (int)[self.imageArray count] / 4 : (int)[self.imageArray count] / 4 + 1;
    
    for (int i = 0; i < row; i ++) {
        for (int j = 0; j < 4; j ++) {
            if (i * 4 + j == self.imageArray.count) {
                break;
            }
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(j * 90, i * 90, 80, 80)];
            [btn setBackgroundImage:self.imageArray[i * 4 + j] forState:UIControlStateNormal];
            [self.myScrollView addSubview:btn];
            
            if (i * 4 + j == self.imageArray.count - 1) {
                [btn addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [btn addTarget:self action:@selector(browseImage:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    CGRect rect = self.myScrollView.frame;
    rect.size.height = row * 80 + 10 * (row - 1);
    self.myScrollView.frame = rect;
    self.myScrollView.contentSize = CGSizeMake(0, row * 80 + 10 * (row - 1));
    self.myScrollView.directionalLockEnabled = YES;
}

- (void)addImage:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"不支持拍照功能" preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:ac animated:YES completion:nil];
        }
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
   
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageArray insertObject:image atIndex:[self.imageArray count] - 1];
    
    [self getImage];
}

- (void)browseImage:(UIButton *)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
