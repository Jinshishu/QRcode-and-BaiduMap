//
//  JSS_ScanQRCodeViewController.h
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnInfoBlock)(NSString *info);

@interface JSS_ScanQRCodeViewController : UIViewController

@property (copy, nonatomic) ReturnInfoBlock infoBlock;

@end
