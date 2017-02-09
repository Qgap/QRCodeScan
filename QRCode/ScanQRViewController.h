//
//  ScanQRViewController.h
//  QRCode
//
//  Created by gap on 17/1/10.
//  Copyright © 2017年 gap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^scanQRResultBlock)(NSString *);

@interface ScanQRViewController : UIViewController

@property (nonatomic,copy) scanQRResultBlock scanQRResult;

@property (nonatomic,strong) UIView *loadingView;

@end
