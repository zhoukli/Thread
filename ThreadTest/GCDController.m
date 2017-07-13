//
//  GCDController.m
//  ThreadTest
//
//  Created by 周凯丽 on 2017/7/13.
//  Copyright © 2017年 caifu. All rights reserved.
//

#import "GCDController.h"

@interface GCDController ()
@property (weak, nonatomic) IBOutlet UILabel *desLbl;

@end

@implementation GCDController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.desLbl.text = @"看注释吧  不写了";
    //GCD中引入了任务（block）和队列（queue） 队列只是用来装任务的容器，具体任务还是要线程来执行 同步异步 是意味着是否创建新的线程
    
    //队列和线程的关系
    //队列是装任务的一个容器       队列分为 串行和并行
    //线程是执行任务的，就是干活的  线程分为 同步和异步
    
    //总结：同步异步决定了要不要开启新线程，串行和并行决定任务的执行方式
    //同步：不具备开辟线程的能力
    //异步：能开辟新线程
    //并发：多个任务并发（同时）执行
    //串行：按顺序执行任务
    
    //1. 串行队列同步执行   不会开辟新线程 在原来的线程里面顺序执行
    //2. 串行队列异步执行   会开辟一个新线程 在新线程里面顺序执行
    //3. 并行队列同步执行   不会开辟新线程 在原来的线程里面顺序执行
    //4. 并行队列异步执行   开多条线程（我们并不能控制开启多少条线程，由GCD底层帮我们完成），并发执行任务
    
    
    //GCD 队列 串行  并行  全局  主队列
    //串行
    //dispatch_queue_t queue =  dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    //并行
    //dispatch_queue_t queue =  dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    //全局队列  是系统的，直接拿过来（GET）用就可以；与并行队列类似，但调试时，无法确认操作所在队列
    //dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //主队列  每一个应用程序对应唯一一个主队列，直接GET即可；在多线程开发中，使用主队列更新UI
    //dispatch_queue_t q = dispatch_get_main_queue();
    
    
    
    //GCD 同步异步操作
    //dispatch_async 异步操作，会并发执行，无法确定任务的执行顺序；
    //dispatch_sync 同步操作，会依次顺序执行，能够决定任务的执行顺序；
    NSLog(@"主线程 == %@",[NSThread mainThread]);
    [self serialQueueSync];
    [self serialQueueAsyn];
    [self concurrentQueueSync];
    [self concurrentQueueAsync];
    [self mainQueueAsync];
}
#pragma mark - 串行队列
//串行队列同步执行
- (void)serialQueueSync
{
    //可以看出和主线程是一个线程
    dispatch_queue_t t = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(t, ^{
        NSLog(@"串行队列同步执行 == %@",[NSThread currentThread]);
    });
    
}
- (void)serialQueueAsyn
{
    //创建一个新线程
    dispatch_queue_t t = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(t, ^{
        NSLog(@"串行队列异步执行 == %@",[NSThread currentThread]);

    });
}
#pragma mark - 并行队列
- (void)concurrentQueueSync
{
    //不会创建一个新线程 还是在主线程上
    dispatch_queue_t t = dispatch_queue_create("currect", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(t, ^{
        NSLog(@"并行队列同步执行1 == %@",[NSThread currentThread]);

    });
    dispatch_sync(t, ^{
        NSLog(@"并行队列同步执行2 == %@",[NSThread currentThread]);
        
    });
}

- (void)concurrentQueueAsync
{
    //创建一个新线程
    dispatch_queue_t t = dispatch_queue_create("currect", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(t, ^{
        NSLog(@"并行队列异步执行1 == %@",[NSThread currentThread]);

    });
    dispatch_async(t, ^{
        NSLog(@"并行队列异步执行2 == %@",[NSThread currentThread]);
        
    });
}
#pragma mark - 主队列
//上面的总结 对于主队列都不实用 统统忘掉吧
//主队列 一个比较特殊的队列  跟其他要区分
//1.当程序启动时，就会创建一个主线程，同时有一个主队列（iOS开发中默认UI更新全在主线程中完成）
//2.主队列负责在主线程上调度任务
//3.异步添加任务到主队列不会开启新线程，任务在主线程中执行
//4.异步添加到主队列的任务并不一定马上执行，而是顺序等待任务执行
//5.同步添加任务到主队列，这是一种十分愚蠢的做法，永远不要这么去做，下面会做说明

//主线程同步执行（会阻塞 最好不要这么写）
- (void)mainQueueSync
{
    dispatch_queue_t t = dispatch_get_main_queue();
    dispatch_sync(t, ^{
        NSLog(@"主线程同步步执行 == %@",[NSThread currentThread]);
 
    });
}
//主线程异步执行（不会开辟线程 并且是顺序执行的）
- (void)mainQueueAsync
{
    dispatch_queue_t t = dispatch_get_main_queue();
    for (NSInteger i = 1; i < 4; i++) {
        dispatch_async(t, ^{
            NSLog(@"主线程异步执行任务第%ld个任务%@",i,[NSThread currentThread]);
        });
    }
}
#pragma mark - 全局队列 与并行队列的区别
//dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//第一个参数是优先级，默认是0  DISPATCH_QUEUE_PRIORITY_DEFAULT = 0
//全局队列和并行队列的区别(这两种队列用法相似)
//1.全局队列没有标示，并行队列有（并行队列的第一个参数）
//2.全局队列供所有应用程序使用
//3.MRC中，并发队列需要我们进行内存管理，全局队列不需要
@end
