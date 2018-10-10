//
//  ViewController+ThreadTest.h
//  MutilThreadTest
//
//  Created by duoyi on 2018/10/10.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController (ThreadTest)

- (void)testGCD;
- (void)testNSOperation;
- (void)testNSThread;

@end

NS_ASSUME_NONNULL_END
