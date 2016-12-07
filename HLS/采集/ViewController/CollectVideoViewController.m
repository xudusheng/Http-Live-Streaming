//
//  CollectVideoViewController.m
//  HLS
//
//  Created by Hmily on 2016/11/30.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "CollectVideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CollectVideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (strong, nonatomic)AVCaptureSession *captureSession;
@property (strong, nonatomic)AVCaptureDeviceInput * currentDeviceInput;

@property (strong, nonatomic)AVCaptureConnection * videoConnection;//用于判断生音频输出还是视频输出
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *previedLayer;
@end

@implementation CollectVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCaputureVideo];
    [self createCollectVideoViewControllerUI];
}


- (void)setupCaputureVideo{
    
    // 1.创建捕获会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 2.获取摄像头设备，指定摄像头方向获取摄像头
    AVCaptureDevice * videoDevice = [self getVideoDevice:AVCaptureDevicePositionFront];

    // 3.获取声音设备
    AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 4.创建对应视频设备输入对象
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    self.currentDeviceInput = videoDeviceInput;

    // 5.创建对应音频设备输入对象
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];

    // 6.添加到会话中
    // 注意“最好要判断是否能添加输入，会话不能添加空的
    // 6.1 添加视频
    if ([_captureSession canAddInput:_currentDeviceInput]) {
        [_captureSession addInput:_currentDeviceInput];
    }
    // 6.2 添加音频
    if ([_captureSession canAddInput:audioDeviceInput]) {
        [_captureSession addInput:audioDeviceInput];
    }
    
    
    
    // 7.获取视频数据输出设备
    AVCaptureVideoDataOutput * videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 7.1 设置代理，捕获视频样品数据
    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t videoQueue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([_captureSession canAddOutput:videoOutput]) {
        [_captureSession addOutput:videoOutput];
    }
    
    // 8.获取音频数据输出设备
    AVCaptureAudioDataOutput * audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t audioQueue = dispatch_queue_create("audioQueue", DISPATCH_QUEUE_SERIAL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    
    // 9.获取视频输入与输出连接，用于分辨音视频数据
    self.videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 10.添加视频预览图层
    
    self.previedLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _previedLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer addSublayer:_previedLayer];
    
    // 11.启动会话
    [_captureSession startRunning];
    
}


//TODO：指定摄像头方向获取摄像头
- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position
{
    //默认是后置摄像头
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)createCollectVideoViewControllerUI{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 40);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleCapture:)
     forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

//TODO：切换摄像头
- (void)toggleCapture:(id)sender {
    
    // 获取当前设备方向
    AVCaptureDevicePosition curPosition = _currentDeviceInput.device.position;
    
    // 获取需要改变的方向
    AVCaptureDevicePosition togglePosition = curPosition == AVCaptureDevicePositionFront?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
    
    // 获取改变的摄像头设备
    AVCaptureDevice *toggleDevice = [self getVideoDevice:togglePosition];
    
    // 获取改变的摄像头输入设备
    AVCaptureDeviceInput *toggleDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toggleDevice error:nil];
    
    
    // 移除之前摄像头输入设备
    [_captureSession removeInput:_currentDeviceInput];
    
    // 添加新的摄像头输入设备
    self.currentDeviceInput = toggleDeviceInput;
    if ([_captureSession canAddInput:_currentDeviceInput]) {
        [_captureSession addInput:_currentDeviceInput];
    }
}


#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    if (_videoConnection == connection) {
        NSLog(@"采集到视频数据");
    } else {
        NSLog(@"采集到音频数据");
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    
}



#pragma mark 聚焦功能


@end
