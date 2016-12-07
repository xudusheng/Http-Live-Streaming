//
//  LiveVideoPlayerViewController.m
//  HLS
//
//  Created by Hmily on 2016/11/30.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "LiveVideoPlayerViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
@interface LiveVideoPlayerViewController ()

@property (strong, nonatomic) IJKFFMoviePlayerController * player;

@end

@implementation LiveVideoPlayerViewController
//videoInfo
//{
//    "creator": {
//        "id": 721330,
//        "level": 61,
//        "gender": 0,
//        "nick": "LZ💃小祖宗 勿忘初心",
//        "portrait": "http://img2.inke.cn/MTQ4MDQyMTI0OTg2NiM3NTcjanBn.jpg"
//    },
//    "id": "1480482307323513",
//    "name": "",
//    "city": "大连市",
//    "share_addr": "http://mlive17.inke.cn/share/live.html?uid=721330&liveid=1480482307323513&ctime=1480482307",
//    "stream_addr": "http://pull99.a8.com/live/1480482307323513.flv",
//    "version": 0,
//    "slot": 5,
//    "optimal": 0,
//    "online_users": 16285,
//    "group": 0,
//    "link": 0,
//    "multi": 0,
//    "rotate": 0
//}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString * videoUrl = self.videoInfo[@"stream_addr"];
//    videoUrl = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream1555";
    videoUrl = @"http://10.3.9.103:1988/hls/133009.m3u8";
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:videoUrl
                                                                   withOptions:nil];
    [_player prepareToPlay];

    [self.view addSubview:_player.view];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_player pause];
    [_player stop];
}

- (void)dealloc{
    _player = nil;
}

@end
