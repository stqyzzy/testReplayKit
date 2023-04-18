//
//  Encoder.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

/*===================================================
        * 文件描述 ：<#文件功能描述必写#> *
 https://juejin.cn/post/6953551392900382734
=====================================================*/

#import <Foundation/Foundation.h>
#import "SenderBuffer.h"
// Core Media framework定义了AVFoundation和Apple平台上的其他高级媒体框架使用的媒体管道。使用Core Media的低级数据类型和接口高效处理媒体样本并管理媒体数据队列。
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN

@interface Encoder : NSObject
- (void)initEncoder:(int)width height:(int)height senderBuffer:(SenderBuffer *)buffer;
// CMSampleBufferRef一帧视频数据或音频数据
- (void)encode:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
