//
//  ViewController+ThreadSyncTest.m
//  MutilThreadTest
//
//  Created by duoyi on 2018/10/10.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController+ThreadSyncTest.h"
#import "ViewController+Thread.h"

#import <os/lock.h>

@implementation ViewController (ThreadSyncTest)

#pragma mark -

- (void)testSynchronized {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread1 %@", [NSThread currentThread]);
        @synchronized (self) {
            NSLog(@"thread1-1 %@", [NSThread currentThread]);
            sleep(3);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread2 %@", [NSThread currentThread]);
        @synchronized (self) {
            NSLog(@"thread2-1 %@", [NSThread currentThread]);
            sleep(4);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread3 %@", [NSThread currentThread]);
        @synchronized (self.token) {
            NSLog(@"thread3-1 %@", [NSThread currentThread]);
            sleep(5);
        }
    });
}

#pragma mark -

- (void)testNSLock {
    NSLock *lock1 = [[NSLock alloc] init];
    NSLock *lock2 = [[NSLock alloc] init];
    
    //相同的锁对象才能锁住
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread1 %@", [NSThread currentThread]);
        [lock1 lock];
        NSLog(@"thread1-1 %@", [NSThread currentThread]);
        sleep(3);
        [lock1 unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread2 %@", [NSThread currentThread]);
        [lock1 lock];
        NSLog(@"thread2-1 %@", [NSThread currentThread]);
        sleep(4);
        [lock1 unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread3 %@", [NSThread currentThread]);
        [lock2 lock];
        NSLog(@"thread3-1 %@", [NSThread currentThread]);
        sleep(5);
        [lock2 unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread4 %@", [NSThread currentThread]);
        [self testLockMethod];
        NSLog(@"thread4-2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread5 %@", [NSThread currentThread]);
        [self testLockMethod];
        NSLog(@"thread5-2 %@", [NSThread currentThread]);
    });
}

- (void)testLockMethod {
    [self.commonLock lock];
    NSLog(@"testLockMethod: %@", [NSThread currentThread]);
    sleep(5);
    [self.commonLock unlock];
}

#pragma mark -

- (void)testNSRecursiveLock {
    //在同一个线程中递归调用才会导致死锁问题，因为线程被阻塞，无法解锁
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self testRecursiveLockMethod];
    });
}

- (void)testRecursiveLockMethod {
    static int recursiveTime = 1;
    if (recursiveTime > 3) return;
    
    //这样写每次都会生成一个锁，不同的锁作用于不同线程，达不到同步效果
//    NSLock *lock1 = [[NSLock alloc] init];
//    NSRecursiveLock *lock1 = [[NSRecursiveLock alloc] init];
    //会造成死锁
//    NSLock *lock1 = self.commonLock;
    NSRecursiveLock *lock1 = self.commonRecursiveLock;
    
    NSLog(@"thread begin1: %@", @(recursiveTime));
    [lock1 lock];
    NSLog(@"thread begin2: %@", @(recursiveTime));
    
    sleep(3);
    recursiveTime++;
    [self testRecursiveLockMethod];

    [lock1 unlock];
    NSLog(@"thread end: %@", @(recursiveTime));
}

#pragma mark -

- (void)testOSSpinLock {
    os_unfair_lock_t unfairLock = &(OS_UNFAIR_LOCK_INIT);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread1 %@", [NSThread currentThread]);
        os_unfair_lock_lock(unfairLock);
        NSLog(@"thread1-1 %@", [NSThread currentThread]);
        sleep(3);
        os_unfair_lock_unlock(unfairLock);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"thread2 %@", [NSThread currentThread]);
        os_unfair_lock_lock(unfairLock);
        NSLog(@"thread2-1 %@", [NSThread currentThread]);
        sleep(3);
        os_unfair_lock_unlock(unfairLock);
    });
}

#pragma mark -

- (void)testNSCondition {
    
}

#pragma mark -

- (void)testCondition {
    
}

#pragma mark -

- (void)testSemphorate {
    
}

@end
