//
//  TimeManager.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/18.
//

#import "TimeManager.h"

@interface TimeManager()

@end

@implementation TimeManager
uint64_t init_ts = 0;
uint64_t grabber_ts = 0;

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
    init_ts = get_us();
}

#pragma mark -
#pragma mark - public methods
+ (instancetype)sharedManager {
    static TimeManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (uint64_t)getTimestamp {
    return get_us(); // 获取系统启动后的时间间隔，单位微秒
}
#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods

#pragma mark -
#pragma mark - getters and setters
// inline关键字，将函数标记为内联函数，内联函数在编译时会直接被展开，而不会生成调用时的开销，从而可以给编译器提供优化的机会，提高代码执行效率。通常内联函数适用于函数体积较小、频繁调用的场景。
static inline uint64_t get_us() {
    struct timespec spec;
    // clock_gettime是获取系统时间，
    // CLOCK_MONOTONIC获取从系统启动到现在的时间，用于计算时间间隔和定时器
    /*时钟源选CLOCK_MONOTONIC主要是考虑到系统的实时时钟可能会在
        程序运行过程中更改，所以存在一定的不确定性，而CLOCK_MONOTONIC
        则不会，较为稳定*/
    clock_gettime(CLOCK_MONOTONIC, &spec); // 返回的结构体中有两个成员变量，tv_sec表示秒数，tv_nsec表示纳秒数
    // 假设系统启动后经过 1.2 秒后运行，可能会得到类似以下的输出：spec.tv_sec 的值为 1，表示系统启动后经过 1 秒；spec.tv_nsec 的值为 200000000，表示系统启动后经过 1.2 秒（1秒 + 0.2秒）的纳秒数
    uint64_t s = spec.tv_sec; // 秒
    uint64_t us = spec.tv_nsec / 1000 + s * 1000 * 1000; // 微秒
    return us; // 系统启动后的时间，微秒
}

@end
