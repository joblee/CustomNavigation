//
//  JLNavigationController.h
//  CustomNavigation
//
//  Created by 1 on 17/2/28.
//  Copyright © 2017年 BlueMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
@interface JLNavigationController : UINavigationController
{
    CGPoint startTouch;
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;
@property (nonatomic, retain) UIView *naviBgView;
@property (nonatomic,assign) BOOL isMoving;
@end
