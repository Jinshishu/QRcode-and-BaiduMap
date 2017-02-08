//
//  JSS_ScanQRCodeViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth   [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight  [[UIScreen mainScreen] bounds].size.height
#define ScreenSize    [[UIScreen mainScreen] bounds].size


#define kBgImgX self.scanImageView.frame.origin.x
#define kBgImgY self.scanImageView.frame.origin.y
#define kBgImgW self.scanImageView.frame.size.width

@interface JSS_ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;
@property (weak, nonatomic) IBOutlet UIButton *openLightButton;

@property (strong, nonatomic) AVCaptureSession *session;
/**
 *有效扫描区域循环往返的一条线（这里用的是一个背景图）
 */
@property (strong, nonatomic) UIImageView *scrollLine;
/**
 *用于记录scrollLine的上下循环状态
 */
@property (assign, nonatomic) BOOL up;
/**
 *计时器
 */
@property (strong, nonatomic) CADisplayLink *link;

@end

@implementation JSS_ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码/条形码";
    self.up = YES;
    
    [self session];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"相册"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(openPhoto)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.openLightButton.layer.cornerRadius = self.openLightButton.frame.size.width / 2;
    self.openLightButton.layer.masksToBounds = YES;
    self.openLightButton.selected = NO;
    self.openLightButton.alpha = 0.6;
    self.openLightButton.layer.borderWidth = 2.0;
    self.openLightButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.openLightButton.backgroundColor = [UIColor whiteColor];
    [self.openLightButton setImage:[UIImage imageNamed:@"turn_off"] forState:UIControlStateNormal];
    
    self.scanImageView.image = [UIImage imageNamed:@"scanBackground"];
    
    //2.添加一个上下循环运动的线条（这里直接是添加一个背景图片来运动）
    [self.view addSubview:self.scrollLine];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.session startRunning];
    //计时器添加到循环中
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

- (UIImageView *)scrollLine {
    if (!_scrollLine) {
        _scrollLine = [[UIImageView alloc]initWithFrame:CGRectMake(kBgImgX, kBgImgY, kBgImgW, 4)];
        _scrollLine.image = [UIImage imageNamed:@"scanLine"];
    }
    return _scrollLine;
}

- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(LineAnimation)];
    }
    return _link;
}

#pragma mark - 线条运动的动画
- (void)LineAnimation {
    if (_up == YES) {
        CGFloat y = self.scrollLine.frame.origin.y;
        y += 2;
        //        [self.scrollLine setY:y];
        CGRect frame = self.scrollLine.frame;
        frame.origin.y = y;
        self.scrollLine.frame = frame;
        
        if (y >= (kBgImgY+kBgImgW-4)) {
            _up = NO;
        }
    }else{
        CGFloat y = self.scrollLine.frame.origin.y;
        y -= 2;
        
        CGRect frame = self.scrollLine.frame;
        frame.origin.y = y;
        self.scrollLine.frame = frame;
        
        if (y <= kBgImgY) {
            _up = YES;
        }
    }
}

- (AVCaptureSession *)session {
    if (!_session) {
        //1.获取输入设备（摄像头）
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //2.根据输入设备创建输入对象
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        if (input == nil) {
            return nil;
        }
        //3.创建元数据的输出对象
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        //4.设置代理监听输出对象输出的数据,在主线程中刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        // 5.创建会话(桥梁)
        AVCaptureSession *session = [[AVCaptureSession alloc]init];
        //实现高质量的输出和摄像，默认值为AVCaptureSessionPresetHigh，可以不写
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        // 6.添加输入和输出到会话中（判断session是否已满）
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        // 7.告诉输出对象, 需要输出什么样的数据 (二维码还是条形码等) 要先创建会话才能设置
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode];
        // 8.创建预览图层
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        //9.设置有效扫描区域，默认整个图层(很特别，1、要除以屏幕宽高比例，2、其中x和y、width和height分别互换位置)
        CGRect rect = CGRectMake(kBgImgY/ScreenHeight, kBgImgX/ScreenWidth, kBgImgW/ScreenHeight, kBgImgW/ScreenWidth);
        output.rectOfInterest = rect;
        //10.设置中空区域，即有效扫描区域(中间扫描区域透明度比周边要低的效果)
//        UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
//        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
//        [self.view addSubview:maskView];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [rectPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(kBgImgX, kBgImgY, kBgImgW, kBgImgW) cornerRadius:1] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = rectPath.CGPath;
        self.maskView.layer.mask = shapeLayer;
        _session = session;
    }
    return _session;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
// 扫描到数据时会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {

        // 1.停止扫描
        [self.session stopRunning];
        // 2.停止冲击波
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        // 3.取出扫描到得数据
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        if (obj) {
            //二维码信息回传
            if (self.infoBlock) {
                self.infoBlock([obj stringValue]);
            }
            [self showInfoWithTitle:@"扫描信息" Message:[obj stringValue]];
        }
    }
}

#pragma mark - 调用相册
- (void)openPhoto {
    //1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    //2.创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    //选中之后大图编辑模式
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate 相册获取的照片进行处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // 1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    //2.从选中的图片中读取二维码数据
    //2.1创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // 2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];
    // 2.3取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        NSString *urlStr = result.messageString;
        //二维码信息回传
        if (self.infoBlock) {
            self.infoBlock(urlStr);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self showInfoWithTitle:@"扫描结果" Message:urlStr];
    }
    
    if (feature.count == 0) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self showInfoWithTitle:@"扫描结果" Message:@"扫描失败"];
    }
}

- (IBAction)openLight:(UIButton *)sender {
    if (sender.selected == YES) {
        [sender setImage:[UIImage imageNamed:@"turn_on"] forState:UIControlStateSelected];
//        sender.backgroundColor = [UIColor whiteColor];
    }else{
        [sender setImage:[UIImage imageNamed:@"turn_off"] forState:UIControlStateNormal];
    }
    sender.selected = !sender.selected;
    [self openLamp:sender.selected];
}

- (void)openLamp:(BOOL)opened {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        
    }
    else {
        if (opened) {
            //开启闪光灯
            if (device.torchMode != AVCaptureTorchModeOn || device.flashMode !=AVCaptureFlashModeOn) {
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
                
            }
        }
        else {
            //关闭闪关灯
            if (device.torchMode != AVCaptureTorchModeOff || device.flashMode != AVCaptureFlashModeOff){
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
            }
        }
    }

}

- (void)showInfoWithTitle:(NSString *)title Message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.session startRunning];
        //计时器添加到循环中
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
