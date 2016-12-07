//
//  BeautifyVideoViewController.m
//  HLS
//
//  Created by Hmily on 2016/11/30.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "BeautifyVideoViewController.h"


@interface BeautifyVideoViewController ()

@property(strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property(strong, nonatomic) GPUImageBilateralFilter * imageBilateralFilter;//磨皮滤镜
@property(strong, nonatomic) GPUImageBrightnessFilter * imageBrightnessFilter;//美白滤镜

@property (strong, nonatomic) UISlider * bilateralFilterSlider;
@property (strong, nonatomic) UISlider * brightnessFilterSlider;

@end

@implementation BeautifyVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupVideoCamara];
    
    [self createBeautifyVideoViewController];
}

- (void)createBeautifyVideoViewController{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    self.bilateralFilterSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, height - 80, width - 60, 20)];
    _bilateralFilterSlider.minimumValue = 1;
    _bilateralFilterSlider.maximumValue = 10;
    _bilateralFilterSlider.maximumTrackTintColor = [UIColor whiteColor];
    [_bilateralFilterSlider addTarget:self
                              action:@selector(bilateralFilter:)
                    forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_bilateralFilterSlider];
    
    self.brightnessFilterSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, height - 30, width - 60, 20)];
    _brightnessFilterSlider.maximumTrackTintColor = [UIColor whiteColor];
    [_brightnessFilterSlider addTarget:self
                               action:@selector(brightnessFilter:)
                     forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brightnessFilterSlider];

}


- (void)setupVideoCamara{
    // 创建视频源
    // SessionPreset:屏幕分辨率，AVCaptureSessionPresetHigh会自适应高分辨率
    // cameraPosition:摄像头方向
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    
    // 创建最终预览View
    GPUImageView * imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    

    // 创建滤镜：磨皮，美白，组合滤镜
    GPUImageFilterGroup * groupFilter = [[GPUImageFilterGroup alloc] init];
    
    // 磨皮滤镜
    self.imageBilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [groupFilter addTarget:_imageBilateralFilter];
    
    // 美白滤镜
    self.imageBrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [groupFilter addTarget:_imageBrightnessFilter];
    
    // 设置滤镜组链
    [_imageBilateralFilter addTarget:_imageBrightnessFilter];
    [groupFilter setInitialFilters:@[_imageBilateralFilter]];//初始滤镜
    groupFilter.terminalFilter = _imageBrightnessFilter;//最终滤镜
    
    // 设置GPUImage响应链，从数据源 => 滤镜 => 最终界面效果
    [groupFilter addTarget:imageView];
    [_videoCamera addTarget:groupFilter];

    
    // 必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中，就能显示了。
    // 开始采集视频
    [_videoCamera startCameraCapture];

}



- (void)bilateralFilter:(UISlider *)sender {
    // 值越小，磨皮效果越好
    // distanceNormalizationFactor取值范围: 大于1。
    CGFloat maxValue = 10;
    _imageBilateralFilter.distanceNormalizationFactor = maxValue - sender.value;
}
- (void)brightnessFilter:(UISlider *)sender {
    _imageBrightnessFilter.brightness = sender.value;
}

@end
