//
//  SenderBuffer.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

/*===================================================
        * 文件描述 ：缓冲队列 *
=====================================================*/

#import <Foundation/Foundation.h>
#import "Frame.h"
NS_ASSUME_NONNULL_BEGIN

@interface SenderBuffer : NSObject
// 先进先出队列，头出，尾进，循环数组管理。
- (instancetype)initWithSize:(NSInteger)size;
- (BOOL)isEmpty;
- (BOOL)isFull;
- (void)enQueue:(Frame *)frame;
- (Frame *)deQueue;
@end

NS_ASSUME_NONNULL_END
