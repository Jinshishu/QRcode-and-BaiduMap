//
//  JSS_WriteView.m
//  Demo-Test
//
//  Created by Daniel on 16/6/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_WriteView.h"

@interface JSS_WriteView ()

@end

@implementation JSS_WriteView

- (NSMutableArray *)pointArray {
    if (_pointArray == nil) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}

- (NSMutableArray *)lineArray {
    if (_lineArray == nil) {
        _lineArray = [NSMutableArray array];
    }
    return _lineArray;
}

- (void)drawRect:(CGRect)rect
{
    //获取当前上下文，
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 10.0f);
    //线条拐角样式，设置为平滑
    CGContextSetLineJoin(context,kCGLineJoinRound);
    //线条开始样式，设置为平滑
    CGContextSetLineCap(context,kCGLineCapRound);
    //查看lineArray数组里是否有线条，有就将之前画的重绘，没有只画当前线条
    if ([self.lineArray count]>0) {
        for (int i=0; i<[self.lineArray count]; i++) {
            NSArray * array=[NSArray
                             arrayWithArray:[self.lineArray objectAtIndex:i]];
            
            if ([array count]>0)
            {
                CGContextBeginPath(context);
                CGPoint myStartPoint=CGPointFromString([array objectAtIndex:0]);
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                
                for (int j=0; j<[array count]-1; j++)
                {
                    CGPoint myEndPoint=CGPointFromString([array objectAtIndex:j+1]);
                    //--------------------------------------------------------
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
                //保存自己画的
                CGContextStrokePath(context);
            }
        }
    }
    //画当前的线
    if ([self.pointArray count]>0)
    {
        CGContextBeginPath(context);
        CGPoint myStartPoint=CGPointFromString([self.pointArray objectAtIndex:0]);
        CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
        
        for (int j=0; j<[self.pointArray count]-1; j++)
        {
            CGPoint myEndPoint=CGPointFromString([self.pointArray objectAtIndex:j+1]);
            //--------------------------------------------------------
            CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
        }
        CGContextSetStrokeColorWithColor(context,[[UIColor blackColor] CGColor]);
        //-------------------------------------------------------
        CGContextSetLineWidth(context, 10.0);
        CGContextStrokePath(context);
    }
}

#pragma mark -
//手指开始触屏开始
static CGPoint MyBeganpoint;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

//手指移动时候发出
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch=[touches anyObject];
    MyBeganpoint=[touch locationInView:self];
    NSString *sPoint=NSStringFromCGPoint(MyBeganpoint);
    [self.pointArray addObject:sPoint];
    [self setNeedsDisplay];
}

//当手指离开屏幕时候
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *array=[NSArray arrayWithArray:self.pointArray];
    [self.lineArray addObject:array];
    self.pointArray=[[NSMutableArray alloc]init];
    
}
//电话呼入等事件取消时候发出
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches Canelled");
}

- (void)clearView {
    [self.pointArray removeAllObjects];
    [self.lineArray removeAllObjects];
    
    [self setNeedsDisplay];
}

//- (UIImage *)saveView {
//    
//    UIView *screenView = self;
//    UIGraphicsBeginImageContext(screenView.bounds.size);
//    [screenView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    NSLog(@"截屏成功");
//    image = [self imageToTransparent:image];
//    return image;
//}
//
///** 颜色变化 */
//void ProviderReleaseData (void *info, const void *data, size_t size)
//{
//    free((void*)data);
//}
//
////颜色替换
//- (UIImage*) imageToTransparent:(UIImage*) image
//{
//    // 分配内存
//    const int imageWidth = image.size.width;
//    const int imageHeight = image.size.height;
//    size_t      bytesPerRow = imageWidth * 4;
//    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
//    
//    // 创建context
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
//                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
//    
//    // 遍历像素
//    int pixelNum = imageWidth * imageHeight;
//    uint32_t* pCurPtr = rgbImageBuf;
//    for (int i = 0; i < pixelNum; i++, pCurPtr++)
//    {
//        //把绿色变成黑色，把背景色变成透明
//        if ((*pCurPtr & 0x65815A00) == 0x65815a00)    // 将背景变成透明
//        {
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[0] = 0;
//        }
//        else if ((*pCurPtr & 0x00FF0000) == 0x00ff0000)    // 将绿色变成黑色
//        {
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[3] = 0; //0~255
//            ptr[2] = 0;
//            ptr[1] = 0;
//        }
//        else if ((*pCurPtr & 0xFFFFFF00) == 0xffffff00)    // 将白色变成透明
//        {
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[0] = 0;
//        }
//        else
//        {
//            // 改成下面的代码，会将图片转成想要的颜色
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[3] = 0; //0~255
//            ptr[2] = 0;
//            ptr[1] = 0;
//        }
//        
//    }
//    // 将内存转成image
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
//    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
//                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
//                                        NULL, true, kCGRenderingIntentDefault);
//    CGDataProviderRelease(dataProvider);
//    
//    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
//    
//    // 释放
//    CGImageRelease(imageRef);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
//    
//    return resultUIImage;
//}


@end
