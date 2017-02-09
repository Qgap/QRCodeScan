//
//  QRCodeViewController.m
//  NeiruShop
//
//  Created by gap on 17/1/12.
//  Copyright © 2017年 com.leqee. All rights reserved.
//
#import "ScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanView.h"
#import <MBProgressHUD.h>
#import <CoreImage/CoreImage.h>
#import "AppDelegate.h"
#import "ScanResultViewController.h"

static SystemSoundID soundID = 0;

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) ScanView *scanView;

@end

@implementation ScanQRViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"二维码";
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight -64)];
    self.loadingView.backgroundColor = [UIColor blackColor];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake((kScreenWidth - 50)/2., (kScreenHeight - 64 - 70)/2. , 50, 50)];
    [self.loadingView addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;//loading，默认值
    hud.label.textColor = [UIColor whiteColor];
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.label.text = @"加载中";
    [hud showAnimated:YES];

    
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadingView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.loadingView];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(openPhotoAlbum)];
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.session) {
        [self checkoutDeviceCameraStatus];
    }
    self.navigationController.navigationBarHidden = NO;
    [self.scanView startTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view addSubview:self.scanView];
    //    self.loadingView.hidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect cropRect = CGRectMake((self.scanView.frame.size.width - self.scanView.showSize.width) / 2,
                                 (self.scanView.frame.size.height - self.scanView.showSize.height) / 2,
                                 self.scanView.showSize.width,
                                 self.scanView.showSize.height);
    CGSize size = self.scanView.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    
    
    if (p1 < p2) {
        CGFloat fixHeight = self.scanView.frame.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        self.output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                cropRect.origin.x/size.width,
                                                cropRect.size.height/fixHeight,
                                                cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.scanView.frame.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        self.output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                (cropRect.origin.x + fixPadding)/fixWidth,
                                                cropRect.size.height/size.height,
                                                cropRect.size.width/fixWidth);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanView endTimer];
}

#pragma mark - ButtonAction

- (void)openLights:(id)sender {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.torchMode == AVCaptureTorchModeOff) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
//        [openFlashLightButton setTitle:@"关灯" forState:UIControlStateNormal];
    } else{
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
//        [openFlashLightButton setTitle:@"开灯" forState:UIControlStateNormal];
    }
}


- (void)openPhotoAlbum {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info : %@",info);
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    // 将识别类型初始化为二维码
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(image)]];
        if (features.count >= 1) {
            CIQRCodeFeature *feature = features[0];
            NSString *scannedResult = feature.messageString;
//            [self showAlertWithMessage:scannedResult];
            [self showResult:scannedResult];
        } else {
            [self showAlertWithMessage:@"没有二维码"];
            [self.scanView startTimer];
        }
        
    }];
}

#pragma mark - Getter && Setter

- (ScanView *)scanView {
    if (!_scanView) {
        _scanView = [[ScanView alloc] initWithFrame:self.view.bounds];
        _scanView.showSize = CGSizeMake(260*SCREEN_SCALE_W, 260*SCREEN_SCALE_W);
        _scanView.vc = self;
    }
    
    return _scanView;
}

#pragma mark - Prviate Method

- (void)checkoutDeviceCameraStatus {
    if (![self isCameraValid]) {
        [self showAlertWithMessage:@"当前设备相机不可用"];
        return;
    }
    
    if (![self isCameraAllowed]) {
        [self showAlertWithMessage:@"请在iPhone的“设置－隐私－相机”选项中，允许美会说－美店版访问你的相机。"];
    } else {
        [self setupCamera];
    }
}

- (void)setupCamera {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    // 设置扫码支持的编码格式
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.session startRunning];
    
    //    [self.scanView startTimer];
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    //添加播放声音
    NSURL *pathURL = [[NSBundle mainBundle] URLForResource:@"qrcode_found" withExtension:@"wav"];
    if (pathURL) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    [self.session stopRunning];
//    [self.scanView endTimer];
    
    if ([metadataObjects count] > 0) {
        
        // 解析二维码扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        NSLog(@"metadataObject stringValue :%@",metadataObject.stringValue);
        [self showResult:metadataObject.stringValue];
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(BOOL)isCameraAllowed {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

/**
 判断摄像头是否可用
 */
-(BOOL)isCameraValid {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (void)showResult:(NSString *)resultString {
    ScanResultViewController *resultVC = [[ScanResultViewController alloc] init];
    resultVC.resultString = resultString;
    [self.navigationController pushViewController:resultVC animated:YES];
}

@end

