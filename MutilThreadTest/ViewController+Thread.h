//
//  ViewController+ViewController_Thread.h
//  MutilThreadTest
//
//  Created by duoyi on 2018/10/10.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController ()

@property (strong, nonatomic)   dispatch_queue_t queue;
@property (strong, nonatomic)   NSString *token;
@property (strong, nonatomic)   NSLock *commonLock;
@property (strong, nonatomic)   NSRecursiveLock *commonRecursiveLock;

@end

NS_ASSUME_NONNULL_END
