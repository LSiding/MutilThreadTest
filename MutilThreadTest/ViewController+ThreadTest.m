//
//  ViewController+ThreadTest.m
//  MutilThreadTest
//
//  Created by duoyi on 2018/10/10.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController+ThreadTest.h"
#import "ViewController+Thread.h"

@implementation ViewController (ThreadTest)

#pragma mark - GCD

/**
 dispatch_async:产生新线程（主线程队列除外，因为如果创建了新线程，因为是串行队列，则会阻塞主线程），并且任务的执行不会阻塞当前线程，直接返回
 dispatch_sync:不产生新线程，任务的执行会阻塞当前线程，等待任务执行完成后返回
 
 DISPATCH_QUEUE_SERIAL: 添加到队列中的任务会一个接一个地执行
 DISPATCH_QUEUE_CONCURRENT: 添加到队列中的任务可以并发地执行
 */
- (void)testGCD {
    self.queue = dispatch_queue_create("test_queue", DISPATCH_QUEUE_SERIAL);
    //    self.queue = dispatch_queue_create("test_queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(self.queue, ^{
            NSLog(@"current6 %@", [NSThread currentThread]);
            sleep(5);
        });
        NSLog(@"current6 ******");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(self.queue, ^{
            NSLog(@"current7 %@", [NSThread currentThread]);
            sleep(4);
        });
        NSLog(@"current7 ******");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(self.queue, ^{
            NSLog(@"current8 %@", [NSThread currentThread]);
            sleep(2);
        });
        NSLog(@"current8 ******");
    });
    
    dispatch_async(self.queue, ^{
        NSLog(@"current1 %@", [NSThread currentThread]);
        sleep(3);
    });
    
    NSLog(@"------");
    
    dispatch_sync(self.queue, ^{
        NSLog(@"current2 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(self.queue, ^{
        NSLog(@"current3 %@", [NSThread currentThread]);
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"current4 %@", [NSThread currentThread]);
        sleep(2);
    });
    
    dispatch_sync(self.queue, ^{
        NSLog(@"current5 %@", [NSThread currentThread]);
    });
    
    //    产生死锁的原因：主线程在dispatch_sync会等待block的完成，而block任务则被添加到了主队列的末尾，主队列是串行队列，因此不会被执行（这个解释是错的，因为如果是这样，就相当于在一个线程执行dispatch_sync方法且是串行队列就必定会死锁，参考前面的例子就不会发生死锁。所以死锁其实是串行队列死锁而不是线程死锁）
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    //        NSLog(@"current9 %@", [NSThread currentThread]);
    //        sleep(2);
    //    });
    //    可以理解成实际上是这样的调用：
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            NSLog(@"current9 %@", [NSThread currentThread]);
    //            sleep(2);
    //        });
    //    });
    //    既然可以使用主队列，那么可以说明主线程的任务执行也是通过GCD来实现的。第一层dispatch_sync也可以替换成dispatch_async，纯属猜想。
    
    
    //    DISPATCH_QUEUE_SERIAL: 会造成死锁。因为新线程执行dispatch_sync的block时，block需要依赖前面一个block的执行完成。
    //    DISPATCH_QUEUE_CONCURRENT: 不会造成死锁。因为新线程执行dispatch_sync的block时，因为不是串行队列所以没有依赖关系，可以直接执行。
    //    dispatch_async(self.queue, ^{
    //        dispatch_sync(self.queue, ^{
    //            NSLog(@"current10 %@", [NSThread currentThread]);
    //        });
    //        NSLog(@"current10 ****** %@", [NSThread currentThread]);
    //    });
    
    //    也就是说死锁是由于队列依赖引起的，而不是线程。
}

#pragma mark - NSOperation

- (void)testNSOperation {
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(testInvocation) object:nil];
    [invocationOperation start];
    NSLog(@"--------");
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation1 %@", [NSThread currentThread]);
        sleep(3);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation2 %@", [NSThread currentThread]);
        sleep(3);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation3 %@", [NSThread currentThread]);
        sleep(3);
    }];
    //    [blockOperation start];
    [invocationOperation addDependency:blockOperation];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    //    [queue addOperation:invocationOperation];
    [queue addOperation:blockOperation];
    [queue addOperationWithBlock:^{
        NSLog(@"NSOperationQueueBlock1 %@", [NSThread currentThread]);
        [queue setSuspended:YES];
        NSLog(@"NSOperationQueueBlock2 %@", [NSThread currentThread]);
        sleep(3);
        [queue setSuspended:NO];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"NSOperationQueueBlock3 %@", [NSThread currentThread]);
    }];
}

- (void)testInvocation {
    NSLog(@"NSInvocationOperation %@", [NSThread currentThread]);
    sleep(3);
}

#pragma mark - NSThread

- (void)testNSThread {
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething1:) object:@"NSThread1"];
    [thread1 start];
    
    [NSThread detachNewThreadSelector:@selector(doSomething2:) toTarget:self withObject:@"NSThread2"];
    
    [self performSelectorInBackground:@selector(doSomething3:) withObject:@"NSThread3"];
    
}

- (void)doSomething1:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething1：%@",[NSThread currentThread]);
}

- (void)doSomething2:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething2：%@",[NSThread currentThread]);
}

- (void)doSomething3:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething3：%@",[NSThread currentThread]);
}


@end
