//
//  NSOperationController.m
//  ThreadTest
//
//  Created by 周凯丽 on 2017/7/13.
//  Copyright © 2017年 caifu. All rights reserved.
//

#import "NSOperationController.h"

@interface NSOperationController ()
@property (weak, nonatomic) IBOutlet UILabel *desLbl;

@end

@implementation NSOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.desLbl.text = @"NSOperation  NSOperationQueue 分别对应于GCD的 block 和queue 都是任务和队列，比GCD多了设置最大并发量，取消队列，挂起等功能。";
    // NSOperation  NSOperationQueue 分别对应于GCD的 block 和queue 都是任务和队列
    // NSOperationQueue没有串行队列  都是并行的
    // 比GCD 多了的设置最大并发量功能 队列取消 挂起等功能
    // NSOperationQueue的设置依赖关系 功能类似于GCD的调度功能
    
    //使用步骤
    //1.将要执行的任务封装到一个 NSOperation 对象中。
    //2.将此任务添加到一个 NSOperationQueue 对象中。
    
    // NSOperation 只是一个抽象类，所以不能封装任务。但它有 2 个子类用于封装任务。分别是：NSInvocationOperation 和 NSBlockOperation 。创建一个 Operation 后，需要调用 start 方法来启动任务，它会 默认在当前队列异步执行。
    NSLog(@"主线程是%@",[NSThread mainThread]);
    [self operationCreat1];
    [self operationCreat2];
    [self operationCreat3];
    [self operationCreat4];
    [self mainQueue];
    [self dependRelation];
}
#pragma mark - NSInvocationOperation
//NSInvocationOperation
- (void)operationCreat1
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(methods) object:nil];
    [queue addOperation:operation];
}
- (void)methods
{
    
    NSLog(@"当前线程是：%@",[NSThread currentThread]);
}
#pragma mark - NSBlockOperation
//NSBlockOperation
- (void)operationCreat2
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation 当前线程是：%@",[NSThread currentThread]);
    }];
    [queue addOperation:operation];
}
//NSBlockOperation 额外添加任务 addExecutionBlock
- (void)operationCreat4
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation 当前线程是：%@",[NSThread currentThread]);
    }];
    
    [operation addExecutionBlock:^{
        NSLog(@"当前线程是：%@",[NSThread currentThread]);
        
    }];
    [queue addOperation:operation];
}

#pragma mark - NSOperationQueue直接添加
//NSOperationQueue 直接添加  最简单的方法这是
- (void)operationCreat3
{
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        NSLog(@"NSBlockOperation 当前线程是：%@",[NSThread currentThread]);
 
    }];
}
#pragma mark - 主线程
//[NSOperationQueue mainQueue]; 主队列的任务只能在主线程执行
- (void)mainQueue
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSOperationQueue *main = [NSOperationQueue mainQueue];
    [queue addOperationWithBlock:^{
        NSLog(@"NSBlockOperation 当前线程是：%@",[NSThread currentThread]);

        [main addOperationWithBlock:^{
            NSLog(@"main 当前线程是：%@",[NSThread currentThread]);

        }];
    }];
}
#pragma mark - 依赖关系
- (void)dependRelation
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1111 当前线程是：%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"222 当前线程是：%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"333 当前线程是：%@",[NSThread currentThread]);
    }];
    [op1 addDependency:op3];
    [op3 addDependency:op2];
    [queue addOperations:@[op1,op2,op3] waitUntilFinished:YES];
    NSLog(@"444 当前线程是：%@",[NSThread currentThread]);

}
@end
