//
//  Frame.h
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

/*===================================================
        * 文件描述 ：帧结构 *
=====================================================*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Frame : NSObject
@property (nonatomic, assign) uint64_t timetamp;
@property (nonatomic, strong) NSData *jpegData;
@end

NS_ASSUME_NONNULL_END
