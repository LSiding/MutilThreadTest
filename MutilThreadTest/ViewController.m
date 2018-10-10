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
#import "ViewController+ThreadSyncTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.token = @"token";
    self.commonLock = [[NSLock alloc] init];
    self.commonRecursiveLock = [[NSRecursiveLock alloc] init];
    
    NSLog(@"current thread %@", [NSThread currentThread]);
    
//    [self testGCD];
//    [self testNSOperation];
//    [self testNSThread];
    
    //Thread Sync
//    [self testSynchronized];
//    [self testNSLock];
    [self testNSRecursiveLock];
}

@end
