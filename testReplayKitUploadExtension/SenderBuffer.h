//
//  SenderBuffer.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

/*===================================================
        * 文件描述 ：<#文件功能描述必写#> *
=====================================================*/

#import <Foundation/Foundation.h>
#import "Frame.h"
NS_ASSUME_NONNULL_BEGIN

@interface SenderBuffer : NSObject
- (instancetype)initWithSize:(NSInteger)size;
- (BOOL)isEmpty;
- (BOOL)isFull;
- (void)enQueue:(Frame *)jpegData;
- (Frame *)deQueue;
@end

NS_ASSUME_NONNULL_END
