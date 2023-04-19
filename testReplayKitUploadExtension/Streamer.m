//
//  Streamer.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/19.
//

#import "Streamer.h"
#import "TimeManager.h"

@interface Streamer()
@property (nonatomic, assign) char *watcher_ip;
@property (nonatomic, assign) int watcher_port;
@property (nonatomic, strong) SenderBuffer *senderBuffer;
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) init period;
@property (nonatomic, strong) TimeManager *timeManager;
@end

@implementation Streamer

#pragma mark -
#pragma mark - life cycle - 生命周期
- (void)dealloc{
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

#pragma mark -
#pragma mark - init setup - 初始化
- (void)setup{
    [self setDefault];//初始化默认数据
}

/// 设置默认数据
- (void)setDefault{
    
}

#pragma mark -
#pragma mark - public methods
- (Streamer *)createStreamrWithWatchIP:(char *)ip port:(int)port senderBuffer:(SenderBuffer *)buffer {
    self.watcher_ip = ip;
    self.watcher_port = port;
    self.senderBuffer = buffer;
    self.fps = 15;
    self.period = 1000000/ self.fps;
    self.timeManager = [TimeManager sharedManager];
    return self;
}

#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods

#pragma mark -
#pragma mark - getters and setters


@end
