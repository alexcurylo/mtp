// @copyright Trollwerks Inc.

#import "MemoryWarner.h"

@implementation MemoryWarner

- (void)performMemoryWarningEvery:(NSTimeInterval)seconds
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)timerFireMethod:(NSTimer *) __unused theTimer
{
    [[UIApplication sharedApplication] _performMemoryWarning];
}

@end
