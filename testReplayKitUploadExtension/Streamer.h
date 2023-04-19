//
//  Streamer.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/19.
//

/*===================================================
        * 文件描述 ：<#文件功能描述必写#> *
=====================================================*/

#import <Foundation/Foundation.h>
#import "SenderBuffer.h"
NS_ASSUME_NONNULL_BEGIN

@interface Streamer : NSObject
- (void)stream;
- (Streamer *)createStreamrWithWatchIP:(char *)ip port:(int)port senderBuffer:(SenderBuffer *)buffer;
@end

NS_ASSUME_NONNULL_END
