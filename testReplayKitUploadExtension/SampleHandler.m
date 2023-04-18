//
//  SampleHandler.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//


#import "SampleHandler.h"
#import "SenderBuffer.h"
#import "Encoder.h"

// Broadcast Upload Extension是在录制配置界面完成后，在录制期间触发事件回调和录制的音视频数据回调，开发者可以在此回调中处理逻辑。
@interface SampleHandler ()
@property (nonatomic, strong) SenderBuffer *senderBuffer;
@property (nonatomic, strong) Encoder *encoder;
@end

@implementation SampleHandler

#pragma mark -
#pragma mark - init setup - 初始化

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NSInteger bufferSize = 30;
    [self createSenderBufferWithSize:bufferSize];
    [self initializeEncoder];
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
    
}
#pragma mark -
#pragma mark - getters and setters



@end
