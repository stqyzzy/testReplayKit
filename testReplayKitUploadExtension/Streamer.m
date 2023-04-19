//
//  Streamer.m
//  testReplayKitUploadExtension
//
//  Created by 云中追月 on 2023/4/19.
//

#import "Streamer.h"
#import "TimeManager.h"
#import <netinet/in.h>
#import <arpa/inet.h>

@interface Streamer()
@property (nonatomic, assign) char *watcher_ip;
@property (nonatomic, assign) int watcher_port;
@property (nonatomic, strong) SenderBuffer *senderBuffer;
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) int period;
@property (nonatomic, strong) TimeManager *timeManager;
@end
#define PACKET_MAGIC 0x87654321
#define PACKET_TYPE_FRAME 0x01

const unsigned int packet_size_default = 1024;

struct packet_header {
    uint32_t magic; // 魔法数
    uint16_t type; // 包的类型
    uint16_t length; // 包的长度，包括header
};

struct frame_packet {
    struct packet_header hdr; // 包的头部
    uint32_t fid; // frame ID
    uint32_t total_length; // 此帧的总长度，以字节为单位传输
    
    uint32_t pid; // packet ID
    uint32_t total_packets; // 总共的包数量
    uint32_t offset; // 当前包在帧中的字节偏移量
    uint32_t length; // 当前包的有效载荷
    
    uint64_t timestamp;
    char data[0]; // 载荷的指针
};
@implementation Streamer

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
- (Streamer *)createStreamrWithWatchIP:(char *)ip port:(int)port senderBuffer:(SenderBuffer *)buffer {
    self.watcher_ip = ip;
    self.watcher_port = port;
    self.senderBuffer = buffer;
    self.fps = 15;
    self.period = 1000000/ self.fps;
    self.timeManager = [TimeManager sharedManager];
    return self;
}

- (void)stream {
    struct sockaddr_in watcher_addr; // sockaddr_in是一个用于表示IP地址和端口号的结构体
    int watcher_fd;
    struct timespec idle;
    idle.tv_sec = 0; // 秒
    idle.tv_nsec = 1000 * 1000; // 纳秒
    // domain地址族 type套接字类型，SOCK_DGRAM代表UDP套接字 protocol传输协议
    watcher_fd = socket(AF_INET, SOCK_DGRAM, 0); // 返回一个套接字描述符，是对套接字的引用，可以使用这个描述对套接字进行操作，如发送数据、接收数据和关闭套接字等。
    // 将一块内存区域的值设置为指定的值，s参数是指向要填充的内存区域的指针，c是要设定的值，n是要填充的字节数
    memset(&watcher_addr, 0, sizeof(watcher_addr)); // 将watcher_addr变量的值设置为0
    watcher_addr.sin_family = AF_INET; // 地址族，必须设置为AF_INET
    watcher_addr.sin_addr.s_addr = inet_addr(self.watcher_ip); // IP地址，使用网络字节序，32位IPv4地址
    watcher_addr.sin_port = htons(self.watcher_port); // 将一个16位的二进制数从主机字节序变换为网络字节序，网络字节序的顺序和主机字节序的顺序是相反的
    
    uint32_t fid;
    for (fid = 0; ; fid++) {
        Frame *frame;
        if (![self.senderBuffer isEmpty]) {
            @autoreleasepool {
                frame = [self.senderBuffer deQueue];
            }
        }
        size_t frame_len_encoded = [frame.jpegData length]; // 数据的字节数
        __block unsigned char *frame_buffer_final = NULL;
        [frame.jpegData enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
            frame_buffer_final = (unsigned char *)bytes;
        }];
        
        uint32_t frame_size_final = frame_len_encoded; // 数据的字节数
        uint32_t total_packets = frame_size_final / packet_size_default + (frame_size_final % packet_size_default > 0); // 转换成M
        int ret = send_frame(fid, frame_buffer_final, frame.timetamp, frame_size_final, packet_size_default, watcher_fd, watcher_addr);
        if (ret < 0) {
            NSLog(@"error in send_frame()!!!");
        }
        uint64_t next_streamer_ts = init_ts + self.period * (fid + 1);
        uint64_t ts = [self.timeManager getTimestamp];
        while (ts < next_streamer_ts) {
            nanosleep(&idle, NULL);
            ts = [self.timeManager getTimestamp];
        }
    }
}
#pragma mark -
#pragma mark - <#custom#> Delegate

#pragma mark -
#pragma mark - private methods
// fid 帧ID frame帧 timestamp时间戳 frame_size帧大小 packet_size包大小 watcher_fd对套接字的引用 watcher_addr IP地址
int send_frame(uint32_t fid, unsigned char *frame, uint64_t timestamp, uint32_t frame_size, uint32_t packet_size, int watcher_fd, struct sockaddr_in watcher_addr) {
    // 分割帧, 添加header， 并且把帧发送到指定的地址
    int ret = 0;
    uint32_t packet_id = 0;
    uint32_t total_packet = frame_size / packet_size + (frame_size % packet_size > 0); // 分片后，是否还有值，如果还有则增加一个切片
    uint32_t remain = frame_size;
    uint32_t offset = 0;
    uint32_t len = (remain >= packet_size) ? packet_size : remain; // 最大长度是包的最高载荷
    char packet_buffer[64 * 1024];
    // UDP的包有效载荷最多是64K，我们为header保留64B
    if (packet_size > 64 * 1023) {
        return -1;
    }
    while (offset < frame_size) {
        // 填充包头
        struct frame_packet *packet = (struct frame_packet *)packet_buffer;
        // 结构体指针必须使用->访问成员变量，否则会报错。结构体变量可以使用.去访问成员变量
        packet->hdr.magic = PACKET_MAGIC;
        packet->hdr.type = PACKET_TYPE_FRAME;
        packet->hdr.length = sizeof(struct frame_packet) + len;
        
        packet->fid = fid;
        packet->total_length = frame_size;
        packet->pid = packet_id;
        packet->total_packets = total_packet;
        packet->offset = offset;
        packet->length = len; // 包长度，最多是包默认的大小1024
        packet->timestamp = timestamp;
        // 将一个内存区域复制到另一个内存区域
        memcpy(packet->data, frame+offset, len);
        // 用于将数据通过UDP协议发送到指定的目标地址
        ret = sendto(watcher_fd, packet, len + sizeof(struct frame_packet), 0, (struct sockaddr *)&watcher_addr, sizeof((watcher_addr)));
        if (ret <= 0) {
            printf(@"error in send_frame(): %d, %s\n", ret, strerror(errno));
            return ret;
        }
        
        packet_id++;
        remain -= len;
        offset += len;
        len = (remain >- packet_size) ? packet_size : remain;
    }
    
    return packet_id;
    
}
#pragma mark -
#pragma mark - getters and setters


@end
