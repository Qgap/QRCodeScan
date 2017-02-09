//
//  ViewController.m
//  QRCode
//
//  Created by gap on 17/1/9.
//  Copyright © 2017年 gap. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRViewController.h"
#import <CoreImage/CoreImage.h>

@interface ViewController ()
@property (nonatomic,strong) UITextField *inputField;
@property (nonatomic,strong) UIImageView *qrImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 20);
    [button setTitle:@"扫一扫" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(scanQR:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *createQRBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createQRBtn.frame = CGRectMake(100, 150, 100, 20);
    [createQRBtn setTitle:@"创建二维码" forState:UIControlStateNormal];
    [createQRBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [createQRBtn addTarget:self action:@selector(createQRCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createQRBtn];
    
    
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(100, 180, 100, 20)];
    self.inputField.textColor = [UIColor redColor];
    self.inputField.layer.borderColor = [UIColor blackColor].CGColor;
    self.inputField.layer.borderWidth = 1;
    self.inputField.text = @"HELLO GAQ";
    [self.inputField becomeFirstResponder];
    [self.view addSubview:self.inputField];
    
    self.qrImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 210, 100, 100)];
    self.qrImage.layer.borderWidth = 0.5;
    self.qrImage.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:self.qrImage];
    
}



- (void)scanQR:(UIButton *)sender {
    ScanQRViewController *scanQR = [[ScanQRViewController alloc] init];
    [self.navigationController pushViewController:scanQR animated:YES];
    
}

- (void)createQRCodeAction {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [self.inputField.text dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *outputImage = [filter outputImage];
    self.qrImage.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:100];
}


/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
