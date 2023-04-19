//
//  SampleHandler.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//


#import "SampleHandler.h"
#import "SenderBuffer.h"
#import "Encoder.h"
#import "Streamer.h"
#import "TimeManager.h"
// Broadcast Upload Extension是在录制配置界面完成后，在录制期间触发事件回调和录制的音视频数据回调，开发者可以在此回调中处理逻辑。
@interface SampleHandler ()
@property (nonatomic, strong) SenderBuffer *senderBuffer;
@property (nonatomic, strong) Encoder *encoder;
@property (nonatomic, strong) Streamer *streamer;
@property (nonatomic, strong) NSThread *streamerThread;
@property (nonatomic, strong) TimeManager *timeManager;
@end
char *ip = "172.20.10.14";
int port = 32000;
int bufferSize = 30;
@implementation SampleHandler

#pragma mark -
#pragma mark - init setup - 初始化

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NSInteger bufferSize = 30;
    [self createSenderBufferWithSize:bufferSize];
    [self initializeEncoder];
    [self createStreamer];
    [self createStreamerThread];
    [self startStreamingThread];
    [self createTimeManager];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.encoder encode:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - public methods


#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods
- (void)createSenderBufferWithSize:(NSInteger)bufferSize {
    self.senderBuffer = [[SenderBuffer alloc] initWithSize:bufferSize];
}

- (void)initializeEncoder {
    self.encoder = [Encoder new];
    [self.encoder initEncoder:(int)[UIScreen mainScreen].bounds.size.width height:(int)[UIScreen mainScreen].bounds.size.height senderBuffer:self.senderBuffer];
}

- (void)createStreamer {
    self.streamer = [[Streamer new] createStreamrWithWatchIP:ip port:port senderBuffer:self.senderBuffer];
}

- (void)createStreamerThread {
    self.streamerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startStreaming) object:nil];
}

- (void)startStreamingThread {
    [self.streamerThread start];
}

- (void)startStreaming {
    [self.streamer stream];
}

- (void)createTimeManager {
    self.timeManager = [TimeManager sharedManager];
}
#pragma mark -
#pragma mark - getters and setters



@end
