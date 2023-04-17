//
//  SenderBuffer.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/17.
//

#import "SenderBuffer.h"

@interface SenderBuffer()
@property (nonatomic, assign) NSInteger front;
@property (nonatomic, assign) NSInteger rear;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation SenderBuffer

#pragma mark -
#pragma mark - life cycle - 生命周期
- (void)dealloc{
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

- (instancetype)initWithSize:(NSInteger)size {
    if (self = [super init]) {
        self.front = 0;
        self.rear = 0;
        self.size = size;
        self.array = [[NSMutableArray alloc] initWithCapacity:size];
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


#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods

#pragma mark -
#pragma mark - getters and setters


@end
