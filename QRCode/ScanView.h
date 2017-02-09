//
//  ScanView.h
//  QRCode
//
//  Created by gap on 17/1/11.
//  Copyright © 2017年 gap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScanQRViewController;

@interface ScanView : UIView

@property (nonatomic,assign) CGSize showSize;

@property (nonatomic,weak) ScanQRViewController *vc;

- (void)endTimer;

- (void)startTimer;

@end
