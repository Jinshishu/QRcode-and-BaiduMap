//
//  JSS_CreateQRCodeViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_CreateQRCodeViewController.h"

@interface JSS_CreateQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputInfoTextField;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;

@end

@implementation JSS_CreateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.QRCodeImageView.layer.borderWidth = 1.0;
    self.QRCodeImageView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (IBAction)createQRCode:(UIButton *)sender {
    [self.inputInfoTextField resignFirstResponder];
    self.QRCodeImageView.image = [self createQRCodeWithString:self.inputInfoTextField.text];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.myBlock != nil) {
        self.myBlock(self.QRCodeImageView.image);
    }
}

/**
 *  生成二维码
 *
 *  @param string         输入的信息（字符串）
 *  @param viewController 调用方法时当前的控制器
 *
 *  @return 返回生成的二维码
 */
- (UIImage *)createQRCodeWithString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"二维码生成信息不能为空" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil]];
//        [self presentViewController:alertController animated:YES completion:nil];
     
        return nil;
    }
    //二维码滤镜
    CIFilter *filer = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //回复滤镜的默认属性
    [filer setDefaults];
    //将字符串转化成NSData
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //通过KVO设置滤镜inputmessage数据
    [filer setValue:data forKey:@"inputMessage"];
    //获取滤镜输出的图像
    CIImage *outputImage = [filer outputImage];
    //将CIImage转化成UIImage,并放大显示
    UIImage *image = [UIImage new];
    image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    return image;
}

/**
 *  改变二维码大小
 *
 *  @param image 传入的image
 *  @param size  设置大小
 *
 *  @return 返回设置好的image
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    //创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
