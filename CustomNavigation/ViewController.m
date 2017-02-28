//
//  ViewController.m
//  CustomNavigation
//
//  Created by 1 on 17/2/16.
//  Copyright © 2017年 BlueMan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];

}
- (void)viewDidLoad {
    [super viewDidLoad];
         // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
