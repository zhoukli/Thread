//
//  ThreadController.m
//  ThreadTest
//
//  Created by 周凯丽 on 2017/7/13.
//  Copyright © 2017年 caifu. All rights reserved.
//

#import "ThreadController.h"

@interface ThreadController ()
@property (weak, nonatomic) IBOutlet UILabel *desLbl;

@end

@implementation ThreadController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  1 NSThread
     *   可以直接操控线程对象，非常直观和方便。但是，它的生命周期还是需要我们手动管理，所以这套方案也是偶尔用用，比如 [NSThread currentThread]，它可以获取当前线程类，你就可以知道当前线程的各种属性，用于调试十分方便。
     *
     */
    self.desLbl.text = @"NSThread 可以直接操控线程对象，非常直观和方便。但是，它的生命周期还是需要我们手动管理，所以这套方案也是偶尔用用，比如 [NSThread currentThread]，它可以获取当前线程类，你就可以知道当前线程的各种属性，用于调试十分方便。\n三种创建方法：\n（detachNewThreadSelector）\n（initWithTarget）\n(performSelectorInBackground)";
    [self createThread1];
    [self createThread2];
    [self createThread3];
    
    NSLog(@"主线程是%@",[NSThread mainThread]);

}
//三种创建线程的方法
- (void)createThread1
{
    //start手动启动线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMethods) object:nil];
    [thread setName:@"方法1 创建的线程"];
    [thread start];
}
- (void)createThread2
{
    //这种方法创建的线程会自动启动
    [NSThread detachNewThreadSelector:@selector(threadMethods) toTarget:self withObject:nil];
    
}
- (void)createThread3
{
    //隐式创建线程  会自动启动
    [self performSelectorInBackground:@selector(threadMethods) withObject:nil];
    
}

- (void) threadMethods
{
    NSLog(@"%@",[NSThread currentThread]);
}

@end
