//
//  JSS_CreateQRCodeViewController.h
//  Demo-Test
//
//  Created by Daniel on 16/6/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnImageBlock)(UIImage *image);

@interface JSS_CreateQRCodeViewController : UIViewController

@property (copy, nonatomic) ReturnImageBlock myBlock;

@end
