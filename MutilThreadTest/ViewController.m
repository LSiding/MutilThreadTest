//
//  ViewController.m
//  MutilThreadTest
//
//  Created by Young on 2018/9/28.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController.h"
#import "ViewController+Thread.h"
#import "ViewController+ThreadTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"current thread %@", [NSThread currentThread]);
    
    [self testGCD];
    //    [self testNSOperation];
    //    [self testNSThread];
}

@end
