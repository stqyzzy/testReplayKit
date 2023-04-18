//
//  TimeManager.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/18.
//

/*===================================================
        * 文件描述 ：<#文件功能描述必写#> *
=====================================================*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeManager : NSObject
extern uint64_t init_ts;
extern uint64_t grabber_ts;
+(instancetype)sharedManager;
- (uint64_t)getTimestamp;
@end

NS_ASSUME_NONNULL_END
