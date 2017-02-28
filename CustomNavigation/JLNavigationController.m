//
//  JLNavigationController.m
//  CustomNavigation
//
//  Created by 1 on 17/2/28.
//  Copyright © 2017年 BlueMan. All rights reserved.
//

#import "JLNavigationController.h"
#define SCREEN_W [[UIScreen mainScreen] bounds].size.width
#define SCREEN_H [[UIScreen mainScreen] bounds].size.height
//效果类型
#define kIsScale 1
//屏幕快照与左边距离
#define kSpace 100
//快照缩放比率
#define kScale 0.9
//快照蒙层透明度
#define kAlpha 0.3

#define kShadowView 10000
@interface JLNavigationController()
{
    UIImageView *_imgView;//切换到下一个控制器前的屏幕快照视图
    double _lastPushTime;
}
@property (nonatomic,assign) BOOL canDragBack;
@end
@implementation JLNavigationController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置导航栏不透明
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
    self.canDragBack = YES;
    self.interactivePopGestureRecognizer.delegate = nil;//禁止系统的右滑返回
    
    //当前控制器加一个快照，防止因下一个控制器隐藏导航栏而影响本控制器界面
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -64, SCREEN_W, SCREEN_H)];
    //左边阴影
    UIImageView *shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menu_shadow"]];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    shadowImageView.tag = kShadowView;
    [self.view addSubview:shadowImageView];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
    
    
}

// 重载push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    double time = [[NSDate date]timeIntervalSince1970];
    if (time - _lastPushTime < 1) {//禁止无聊的用户点击太快
        return;
    }
    _lastPushTime = time;
    [self.screenShotsList addObject:[self capture]];
    _imgView.image = [self.screenShotsList lastObject];
    //延迟，避免在滑动过程中看到
    if ([self.visibleViewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController *vc = (UITableViewController *)self.visibleViewController;
        _imgView.frame = CGRectMake(0, vc.tableView.contentOffset.y, SCREEN_W, SCREEN_H);
    }else{
        _imgView.frame = CGRectMake(0, -64, SCREEN_W, SCREEN_H);
    }
    //过滤，特殊处理
    //    if ([self.visibleViewController isKindOfClass:[TopicGoodDetailViewController class]]) {
    //        _imgView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    //    }
    
    [self.visibleViewController.view addSubview:_imgView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super pushViewController:viewController animated:animated];
    });
    
    [self performSelector:@selector(removeLastControllerScreenShot) withObject:nil afterDelay:0.4];
}

// 重载pop方法
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.screenShotsList.count > 0) {
        [self.screenShotsList removeObjectAtIndex:self.screenShotsList.count-1];
    }
    _imgView.image = [self.screenShotsList lastObject];
    [_imgView removeFromSuperview];

    return [super popViewControllerAnimated:animated];
}
//切换到下一个控制器完毕，移除上一个控制器的屏幕快照
- (void)removeLastControllerScreenShot
{
    [_imgView removeFromSuperview];
}
#pragma mark - Utility Methods -

// 屏幕截图
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, [UIApplication sharedApplication].keyWindow.opaque, 0.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

// 滑动时设置当前view及截图的位置
- (void)moveViewWithX:(float)x
{
    
    x = x>SCREEN_W?SCREEN_W:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    
    float alpha = kAlpha - (x/SCREEN_W);
    blackMask.alpha = alpha;
    
    if (kIsScale) {
        //缩放效果
        float scale = (x/6400)+kScale;
        lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    }else{
        //类似系统的右移效果
        float tempX = x * kSpace/SCREEN_W;
        self.backgroundView.frame = CGRectMake(-kSpace+tempX, self.backgroundView.frame.origin.y, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    }
    //仿系统阴影
    float alp = 1 - x/SCREEN_W;
    UIView *view = [self.view viewWithTag:kShadowView];
    view.alpha = alp;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    //    不需要右滑返回
    //    if ([self.visibleViewController isKindOfClass:[AddPostViewController class]]) {
    //        return;
    //    }
    // 如果只有一个控制器时，直接返回
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // 获取出点在keywindow的位置
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // 开始滑动
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        if (touchPoint.x > 80) {
            return;
        }
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            float originX = kIsScale?0:-kSpace;
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(originX, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        //        [self.backgroundView addSubview:lastScreenShotView];
        //结束滑动
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        float distance = 80;
        if (touchPoint.x - startTouch.x > distance && _isMoving)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:SCREEN_W];
                lastScreenShotView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // 取消滑动
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

@end
