//
//  LivePreviewController.m
//  HLS
//
//  Created by Hmily on 2016/12/5.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "LivePreviewController.h"
#import "LFLiveKit.h"

@interface LivePreviewController ()<LFLiveSessionDelegate>

@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, copy) NSString * streamUrl;//推流的地址

@end

@implementation LivePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self requestAccessForVideo];
    [self requestAccessForAudio];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.startLiveButton];
    
    self.session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration]
                                              videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]
                                                     captureType:LFLiveCaptureDefaultMask];
    
    _session.delegate = self;
    _session.showDebugInfo = NO;
    _session.preView = self.view;
    
    
    //self.streamUrl = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream1555";
    
    //self.streamUrl = @"rtmp://10.3.9.103:1990/liveApp/abc";//RTMP
    
    self.streamUrl = @"http://10.3.9.103:1990/hls/133009";//HLS
    
}


#pragma mark - UI
//TODO：直播按钮
- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        self.startLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(CGRectGetWidth(self.view.bounds) - 60, 44);
        frame.origin = CGPointMake(30, CGRectGetHeight(self.view.bounds) - 90);
        _startLiveButton.frame = frame;
        _startLiveButton.layer.cornerRadius = CGRectGetHeight(frame)/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        [_startLiveButton addTarget:self
                             action:@selector(startLiveButtonClick:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveButton;
}

#pragma mark - 事件响应
- (void)startLiveButtonClick:(UIButton *)startLiveButton{
    _startLiveButton.selected = !_startLiveButton.selected;
    if (_startLiveButton.selected) {
        [_startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        stream.url = _streamUrl;//设置推流地址
        [_session startLive:stream];
    } else {
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_session stopLive];
    }

}
#pragma mark - 设备是否可用
//TODO:判断视频设备是否可用
- (void)requestAccessForVideo {
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            break;
        default:
            break;
    }
}

//TODO:判断音频设备是否可用
- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:{
            // 用户明确地拒绝授权，或者音频设备无法访问
            break;
        }
        default:
            break;
    }
}

#pragma mark - 代理方法
#pragma mark - LFStreamingSessionDelegate
/** 直播状态回调 */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"%s", __FUNCTION__);
    switch (state) {
        case LFLiveReady:
            _stateLabel.text = @"未连接";
            break;
        case LFLivePending:
            _stateLabel.text = @"连接中";
            break;
        case LFLiveStart:
            _stateLabel.text = @"已连接";
            break;
        case LFLiveError:
            _stateLabel.text = @"连接错误";
            break;
        case LFLiveStop:
            _stateLabel.text = @"未连接";
            break;
        default:
            break;
    }
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSLog(@"%s", __FUNCTION__);
}

- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"%s", __FUNCTION__);
}




- (LFLiveSession *)session {
    if (!_session) {

        
    }
    return _session;
}


@end
