//
//  Encoder.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

#import "Encoder.h"
// VideoToolbox是一个低级的框架，可直接访问硬件的编解码器。能够为视频提供压缩和解压缩的服务，同时也提供存储在CoreVideo像素缓冲区的图像进行格式的转换。
// 利用GPU或者专用处理器对视频流进行编解码，不用大量占用CPU资源。性能高，很好的实时性。
#import <VideoToolbox/VideoToolbox.h>
#import "TimeManager.h"
#import <UIKit/UIKit.h>
@interface Encoder()
@property (nonatomic, assign) VTCompressionSessionRef encodingSession; //视频编码器session，即管理编码器上下文的对象
@property (nonatomic, strong) SenderBuffer *senderBuffer;
@end

@implementation Encoder

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
- (void)initEncoder:(int)width height:(int)height senderBuffer:(SenderBuffer *)buffer {
    // 创建视频编码器session，即管理编码器上下文的对象
    // outputCallback设置为NULL的时候，需要调用VTCompressionSessionEncodeFrameWithOutputHandler方法进行压缩帧处理
    OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_JPEG, NULL, NULL, NULL, NULL, NULL, &_encodingSession);
    NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
    if (status != 0) {
        NSLog(@"H264: Unable to create a H264 session");
        return;
    }
    // kVTCompressionPropertyKey_RealTime是否实时执行压缩，false表示视频编码器可以比实时更慢地工作，以生产更好的结果，设置为True可以更加及时的编码。
    VTSessionSetProperty(_encodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    self.senderBuffer = buffer;
}
// CMSampleBufferRef是用于表示媒体采样数据的一种数据结构，它包含了媒体采样的实际数据以及与之相关的元数据，如时间戳、时长、格式等。
- (void)encode:(CMSampleBufferRef)sampleBuffer{
    // 返回包含媒体数据的图片缓冲
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 返回显示时间戳，该时间戳是示例缓冲区中所有样本中最早的数字时间戳。
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    Frame *frame = [Frame new];
    frame.timetamp = grabber_ts - init_ts; // 计算时间戳
    VTEncodeInfoFlags flags; // 有关编码的信息
    
    VTCompressionSessionEncodeFrameWithOutputHandler(_encodingSession, imageBuffer, presentationTimeStamp, kCMTimeInvalid, NULL, &flags, ^(OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef  _Nullable sampleBuffer) {
        if (status != noErr) {
            // 报错
            NSLog(@"JPEG: VTCompressionSessionEncodeFrame failed with %d", (int)status);
            // 结束会话
            VTCompressionSessionInvalidate(_encodingSession);
            CFRelease(_encodingSession);
            _encodingSession = NULL;
            return;
        } else {
            if (!CMSampleBufferDataIsReady(sampleBuffer)) {
                NSLog(@"jpeg data is not ready");
                return;
            }
            // 从CMSampleBuffer中获取媒体的实际数据
            CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t length, totalLength;
            char *dataPointer; // 用于返回数据指针的地址，该指针指向媒体数据的实际缓冲区
            // CMBlockBufferGetDataPointer用于获取CMBlockBufferRef对象中的数据指针
            OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
            if (statusCodeRet == kCMBlockBufferNoErr) {
                frame.jpegData = [[NSData alloc] initWithBytes:dataPointer length:totalLength];
                UIImage *image = [UIImage imageWithData:frame.jpegData];
                if (![self.senderBuffer isFull]) {
                    [self.senderBuffer enQueue:frame];
                }
            }
        }
    });
}
#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods

#pragma mark -
#pragma mark - getters and setters


@end
