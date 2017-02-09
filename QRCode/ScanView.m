
//
//  ScanView.m
//  QRCode
//
//  Created by gap on 17/1/11.
//  Copyright © 2017年 gap. All rights reserved.
//


#import "ScanView.h"
#import <MBProgressHUD.h>
#import "ScanQRViewController.h"



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ScanView ()
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIView *loadingView;
@property (nonatomic,strong) UIButton *lightsButton;

@end

@implementation ScanView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        NSLog(@"scanView Frame : %@",NSStringFromCGRect(frame));
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.lineImageView];
    [self addSubview:self.tipLabel];
    
    self.loadingView = [[UIView alloc] initWithFrame:self.bounds];
    self.loadingView.backgroundColor = [UIColor blackColor];

}

- (void)startTimer {
    if (!self.timer) {
        _timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)endTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer.isValid) {
            [self.timer invalidate];
            self.timer = nil;
        }
    });
}

/**
 line animation
 */
- (void)animationLine {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.vc.loadingView.hidden = YES;
    });
    
    self.showSize = CGSizeEqualToSize(self.showSize, CGSizeZero) ? CGSizeMake(260*SCREEN_SCALE_W, 260*SCREEN_SCALE_W):self.showSize;
    
    [UIView animateWithDuration:2.9 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.lineImageView.frame = CGRectMake((self.frame.size.width - self.showSize.width)/2, 360*SCREEN_SCALE_W -2 + 64, self.showSize.width, 2);
    } completion:^(BOOL finished) {
        self.lineImageView.frame = CGRectMake((self.frame.size.width - self.showSize.width)/2, 100 *SCREEN_SCALE_W + 64, self.showSize.width, 2);
        
    }];
    
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] init];
        _lineImageView.image = [UIImage imageNamed:@"QRcode_bar"];
        //self.center.y - (self.showSize.height) /2.0
        _lineImageView.frame = CGRectMake((self.frame.size.width - self.showSize.width)/2, 100 *SCREEN_SCALE_W + 64, self.showSize.width, 2);
    }
    
    return _lineImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        
        // self.center.y
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,  + 100 * SCREEN_SCALE_W + self.showSize.height+ 79, self.frame.size.width, 30)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"将二维码放入框内，即可自动扫描";
        _tipLabel.textColor = UIColorFromRGB(0x92ff79);
        _tipLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return _tipLabel;
}

- (UIButton *)lightsButton {
    if (!_lightsButton) {
        _lightsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _lightsButton;
}

- (void)drawRect:(CGRect)rect {
    // 判断二维码显示的size
    self.showSize = CGSizeEqualToSize(self.showSize, CGSizeZero) ? CGSizeMake(200, 200):self.showSize;
    //其实就是二维码可扫描范围的frame 200
    CGRect clearDrawRect = CGRectMake((rect.size.width - self.showSize.width)/2.0, 100 *SCREEN_SCALE_W + 64, self.showSize.width, self.showSize.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillContext:ctx rect:self.frame];
    [self addCenterClearContext:ctx rect:clearDrawRect];
    [self addWhiteContext:ctx rect:clearDrawRect];
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
    
}

// 设置整屏颜色，rect ： 改变颜色范围
- (void)addScreenFillContext:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0, 0.5);
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearContext:(CGContextRef)ctx rect:(CGRect)rect {
    // clear the center rect of the layer
    CGContextClearRect(ctx, rect);
}

- (void)addWhiteContext:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextStrokeRect(ctx, rect);
    //    CGContextSetRGBFillColor CGContextSetRGBStrokeColor
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, .8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect {
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 255/225.0, 55/255.0, 112/255.0, 1);
    
    CGFloat originX = rect.origin.x;
    CGFloat originY = rect.origin.y;
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    // 左上角
    CGPoint pointsTopLeftA[] = {
        CGPointMake(originX + 0.7, originY),
        CGPointMake(originX + 0.7, originY + 15)
    };
    CGPoint pointsTopLeftB[] = {
        CGPointMake(originX, originY + 0.7),
        CGPointMake(originX + 15, originY + 0.7)
    };
    [self addLinePointA:pointsTopLeftA pointB:pointsTopLeftB ctx:ctx];
    
    // 左下角
    CGPoint pointsBottomLeftA[] = {
        CGPointMake(originX + 0.7, originY + height - 15),
        CGPointMake(originX + 0.7, originY + height)
    };
    CGPoint pointsBottomLeftB[] = {
        CGPointMake(originX, originY +height - 0.7),
        CGPointMake(originX + 0.7 +15, originY + height - 0.7)
    };
    [self addLinePointA:pointsBottomLeftA pointB:pointsBottomLeftB ctx:ctx];
    
    // 右上角
    CGPoint pointsTopRightA[] = {
        CGPointMake(originX + width -15, originY + 0.7),
        CGPointMake(originX + width, originY + 0.7)
    };
    
    CGPoint pointsTopRightB[] = {
        CGPointMake(originX + width - 0.7, originY),
        CGPointMake(originX + width - 0.7, originY + 15 + 0.7)
    };
    [self addLinePointA:pointsTopRightA pointB:pointsTopRightB ctx:ctx];
    
    // 右下角
    CGPoint pointsBottomRightA[] = {
        CGPointMake(originX + width -0.7, originY + height - 15),
        CGPointMake(originX + width -0.7, originY + height)
    };
    
    CGPoint pointsBottomRightB[] = {
        CGPointMake(originX + width - 15, originY + height - 0.7),
        CGPointMake(originX + width, originY + height - 0.7)
    };
    [self addLinePointA:pointsBottomRightA pointB:pointsBottomRightB ctx:ctx];
    
    CGContextStrokePath(ctx);
}

- (void)addLinePointA:(CGPoint[]) pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}


@end
