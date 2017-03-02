# LiveVideo
---
title: 搭建一个简易的直播APP（iOS版）
date: 2016-12-10
---

{% codeblock %}
###  目录
1、写在前面
2、播放：ijkplayer、VLC
2.1、使用VLC进行播放
2.2、iOS集成ijkplayer进行播放
2.2.1  编译IJKMediaPlayer工程
2.2.2  ijkplayer集成
2.2.1  导出IJKMediaFramework.frameword
2.3、编写iOS代码
3、服务器：nginx+rtmp+ffmpeg
3.1、安装Homebrew
3.2、安装nginx
3.3、配置rtmp
3.4、配置HLS（Http Live Streaming）
4、推流测试（直播模拟）
4.1、使用ffmepg推流测试
4.1.1 安装ffmepg
4.1.2 模拟rtmp直播
4.1.3 模拟HLS点播
4.2、iOS代码推流测试
4.2.1 添加iOS推流代码
4.2.1 模拟rtmp直播
4.2.2 模拟HLS直播
{% endcodeblock %}


## 1、写在前面
&emsp;&emsp;最近又重新翻看了一下iOS相关的点播与直播资料，也踩了不少坑。网上也有不少相关资料，但是完整直播流程一直走不通，要么是电脑推流手机播放，要么是电脑推流电脑播放，至于手机推流的完整demo相对较少，无法很直观的体会完整的手机直播，即手机推流与手机播放。    
&emsp;&emsp;本例将借助nginx+rtmp+ffmpeg搭建一个简单的直播系统，通过手机采集音视频，经过简单的图像处理和编码，再将流推到自己搭建的服务器上（顺带介绍一下电脑推流），最后通过手机和电脑进行播放了。  
&emsp;&emsp;一个完整的直播系统需要涉及到的技术及流程主要包括以下方面：

采集 => 图像处理 => 编码 => 推流 => CDN分发 => 拉流 => 解码 => 播放 => 聊天互动。    

&emsp;&emsp;在本例中，采集=>滤镜处理=>编码=>推流由LFLiveKit来完成，其中图像处理交给GPUImage库完成，而LFLiveKit已经集成了GPUImage库；CDN分发就是搭建的本地服务器；拉流=>解码=>播放由ijkplayer库来完成；聊天互动属于IM范畴，这里就讨论了，有兴趣的朋友可以自行搜索。这里重点是操作，没有太多涉及理论的东西，目的是希望通过一个简单的例子，加深对直播的理解。后续也会慢慢补上直播中各个技术的理论知识与demo。

## 2、播放环境搭建：ijkplayer、VLC
&emsp;&emsp; VLC：电脑版的播放器，用于模拟在电脑端播放。   
&emsp;&emsp; ijkplayer：是基于FFmpeg的跨平台播放器框架，github地址：https://github.com/Bilibili/ijkplayer， iOS版的播放器将使用ijkplayer框架进行集成。  
&emsp;&emsp; 先提供一个播放源数据：http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1, 复制链接到浏览器中打开，会返回一个json格式的数据，其中一个stream_addr的值就是一个播放源。（感谢@袁峥Seemygo提供）。

![image](http://ohlldt20k.bkt.clouddn.com/hls_1_1.png)

### &emsp;&emsp;2.1、Mac端使用VLC进行播放 
&emsp;&emsp;百度下载mac版的VLC进行安装，打开VLC，File -> Open Network…
![image](http://ohlldt20k.bkt.clouddn.com/hls_1_7.png)


### &emsp;&emsp;2.2、iOS集成ijkplayer
#### &emsp;&emsp;2.2.1、ijkplayer集成

##### &emsp;&emsp; a> 下载ijkplayer源码：(下载地址:https://github.com/Bilibili/ijkplayer)  
##### &emsp;&emsp; b> 导入ffmpeg
&emsp;&emsp;ijkplayer是基于ffmpeg这个库的，因此需要导入ffmpeg库  
&emsp;&emsp;打开终端，cd到ijkplayer所在目录，可以看到init-ios.sh的脚本文件，运行脚本文件:

{% codeblock lang:shell%}
$ ./init-ios.sh
{% endcodeblock %}

&emsp;&emsp;等待一段时间....运行完成以后，ios文件夹下面会多出来四个文件夹，分别是ffmpeg-arm64、ffmpeg-armv7、ffmpeg-i386、ffmpeg-x86_64。  
##### &emsp;&emsp; c> 编译ffmpeg库  

{% codeblock %}
//依次执行
//进入ios文件夹
$ cd ios

//删除一些文件和文件夹，为编译ffmpeg.sh做准备，在编译ffmpeg.sh的时候，会自动创建刚刚删除的那些文件，为避免文件名冲突，因此在编译ffmpeg.sh之前先删除等会会自动创建的文件夹或者文件
$ ./compile-ffmpeg.sh clean

//真正的编译各个平台的ffmpeg库，并生成所有平台的通用库。
$ ./compile-ffmpeg.sh all

{% endcodeblock %}

&emsp;&emsp; 双击进入ios文件夹，打开IJKMediaPlayer工程，查看Class-IJKFFMoviePlayerController-ffmpeg-lib下的.a文件，如果文件一片红，说明ffmpeg的编译失败，请重复b、c操作。  
![image](http://ohlldt20k.bkt.clouddn.com/hls_1_8.png)

##### &emsp;&emsp; d> 编译IJKMediaFramework  
&emsp;&emsp;集成ijkplayer的方法有两种，一种是将以上运行成功的IJKMediaPlayer工程中的IJKMediaPlayer.xcodeproj直接导入目标工程，在这里不做介绍;  
&emsp;&emsp;另外一种就是将ijkplayer打包成framework导入工程。  

###### &emsp;&emsp; e.1 打开IJKMediaPlayer工程  

###### &emsp;&emsp; e.2 设置工程的scheme
选择product-Scheme-Edit Scheme
选择run下面的Build Configuration为release，如图
![image](http://ohlldt20k.bkt.clouddn.com/hls_1_2.png)

###### &emsp;&emsp; e.3 设置好scheme以后，分别选择真机和模拟器进行编译（重要：编译前记得clean一下），编译完成以后，选择Product下面的IJKMediaFramework.framework，进入finder，如图
![image](http://ohlldt20k.bkt.clouddn.com/hls_1_6.png)

Release-iphoneos是真机版本的framework，只能跑真机，不能跑模拟器；  
Release-iphonesimulator是模拟器版本的framework，只能跑模拟器，不能跑真机；
如果希望真机与模拟器都能运行，那么就需要对这两个framework进行合并。  

###### &emsp;&emsp; e.4 合并真机与模拟器版本的framework  

//注意：合并的目标是
Release-iphoneos/IJKMediaFramework.framework/IJKMediaFramework  
Release-iphonesimulator/IJKMediaFramework.framework/IJKMediaFramework

{% codeblock %}
//合并代码
//$ lipo -create "真机版路径" "模拟器版路径" -output "合并后的版本路径"
//比如我的：
$ lipo -create /Users/Hmily/Desktop/framework/Release-iphoneos/IJKMediaFramework.framework/IJKMediaFramework /Users/Hmily/Desktop/framework/Release-iphonesimulator/IJKMediaFramework.framework/IJKMediaFramework -output /Users/Hmily/Desktop/framework/IJKMediaFramework
{% endcodeblock %}

复制Release-iphoneos文件夹，粘贴并命名为Release-iphonesimulator-OS
将Release-iphonesimulator-OS/IJKMediaFramework.framework/IJKMediaFramework
替换为刚刚合并生成的IJKMediaFramework
至此，真机与模拟器版的framework制作完成。

![image](http://ohlldt20k.bkt.clouddn.com/hls_1_3.png)

###### &emsp;&emsp; e.5 将IJKMediaFramework.framework集成到xcode工程中
将IJKMediaFramework.framework添加到自己的工程中，并添加以下库支持

AudioToolbox.framework         
AVFoundation.framework
CoreMedia.framework
CoreVideo.framework
libbz2.tbd
libz.tbd
MediaPlayer.framework
MobileCoreServices.framework
OpenGLES.framework
VideoToolbox.framework

### &emsp;&emsp;2.3、编写iOS代码
{% codeblock lang:objc %}
- (void)viewDidLoad {
[super viewDidLoad];
self.view.backgroundColor = [UIColor whiteColor];
NSString * videoUrl = self.videoInfo[@"stream_addr"];
//videoUrl = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream1555";
self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:videoUrl withOptions:nil];
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
{% endcodeblock %}

## 3、服务器搭建：nginx+rtmp+ffmpeg
上面我们完成了播放器的搭建，接下来我们搭建一个属于自己的服务器。
### &emsp;&emsp;3.1、安装Homebrew
打开终端，输入： 
{% codeblock %}
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
{% endcodeblock %}
### &emsp;&emsp;3.2、安装nginx

依次输入以下的命令：
{% codeblock %}
//从github下载Nginx到本地,增加home-brew对nginx的扩展：   
$ brew tap homebrew/nginx

//安装Nginx服务器和rtmp模块:
$ brew install nginx-full --with-rtmp-module

//启动nginx服务器
$ nginx
{% endcodeblock %}
在浏览器地址栏输入：http://localhost:8080 （直接点击）
如果出现下图, 则表示安装成功。 
![image](http://ohlldt20k.bkt.clouddn.com/hls_1_10.png)

### &emsp;&emsp;3.3、配置rtmp

{% codeblock %}
//查看nginx信息
$ brew info nginx-full
{% endcodeblock %}


![image](http://ohlldt20k.bkt.clouddn.com/hls_1_9.png)


打开/usr/local/etc/nginx/nginx.conf文件，在最后面插入以下代码：

{% codeblock %}
rtmp {
server {
listen 9090;            #监听接口号

#RTMP协议
application rmspApp {   #app名称
live on;
record off;          #不记录数据
}

#HLS协议，如果不需要HLS协议，这部分可以删除
#application hls{
#   live on;             #开启实时
#   hls on;              #开始HLS
#   hls_fragment 1s;     #切片时长
#   hls_path /usr/local/var/www/hls;     #ts文件保存路劲
# }
}
}

{% endcodeblock %}

重新加载nginx的配置文件：
{% codeblock %}
$ nginx -s reload

//RTMP推流地址：rtmp://192.168.2.107:9090/rmspApp/133009（133009为模拟的房间号）
//RTMP播放地址：rtmp://192.168.2.107:9090/rmspApp/133009（133009为模拟的房间号）
{% endcodeblock %}

### &emsp;&emsp;3.3、配置HLS(Http Live Streaming)
打开/usr/local/etc/nginx/nginx.conf文件，找到配置http的部分，在'{}'内插入以下配置信息

{% codeblock %}
#这个配置为了`客户端`能够以http协议获取HLS的拉流
server {
listen:9088;
location /hls {
types {
application/vnd.apple.mpegurl m3u8;
video/mp2t ts;
}
root html;
add_header Cache-Control no-cache;
}
}
{% endcodeblock %}

找到rtmp下的server，在'{ }'中增加
{% codeblock %}
#HLS协议
application hls{
live on;             #开启实时
hls on;              #开始HLS
hls_fragment 1s;     #切片时长
hls_path /usr/local/var/www/hls;     #ts文件保存路劲
}
{% endcodeblock %}



重新加载nginx的配置文件：
{% codeblock %}
$ nginx -s reload

//HLS推流地址：http://192.168.2.107:9090/hls/abc
//HLS播放地址：http://192.168.2.107:9088/hls/abc.m3u8(主要端口号的变化)
{% endcodeblock %}




`注意`：HLS中，我们想把推流生成的ts文件存放在`指定的目录`下，比如"/tmp/hls"  

application hls {
live on;
hls on;
hls_path /tmp/hls;
}

那么，我们也需要在http-->server中对root 路径更改为：/tmp 。要不然，会拉不到流。

location /hls {
types {
application/vnd.apple.mpegurl m3u8;
video/mp2t ts;
}
root html;===>更改为root /tmp
//root html 是指使用当前nginx服务器根目录所在位置,指向的是 /usr/local/var/www 这个目录
至此服务器的配置就算完成了，接下来我们进行推流，并进行直播测试

## 4、推流测试

### &emsp;&emsp;4.1、使用ffmepg推流测试  
#### &emsp;&emsp;4.1.1 安装ffmepg
终端输入：
{% codeblock %}
$ brew install ffmpeg
{% endcodeblock %}

#### &emsp;&emsp;4.2.1 模拟rtmp推流(直播)  
使用ffmepg对视频编码  
准备一个视频文件，终端cd到该文件所在的目录：
{% codeblock %}
Hmily$ cd /Users/Hmily/Desktop/rtmp
Hmily$ ls
mtv.mp4

//推流
Hmily$ ffmpeg -re -i mtv.mp4 -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://10.3.9.10:9090/rmspApp/133009
//直播会有多个直播室，这里随便弄一个编号133009模拟

//播放：
//使用FLV播放
//File -> Open Network…
//RUL中输入  rtmp://10.3.9.10:9090/rmspApp/133009

//iOS使用ijkplayer播放
//NSString * videoUrl = @"rtmp://10.3.9.10:9090/rmspApp/133009";
//self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:videoUrl withOptions:nil];
//[_player prepareToPlay];
//[self.view addSubview:_player.view];

{% endcodeblock %}


#### &emsp;&emsp;4.1.3 模拟HLS(点播)  
使用ffmepg对视频编码  
准备一个视频文件，终端cd到该文件所在的目录：
{% codeblock %}
Hmily$ cd /Users/Hmily/Desktop/hls
Hmily$ ls
mtv.mp4

//编码切片
Hmily$ ffmpeg -i mtv.mp4 -c:v libx264 -c:a copy -f hls mtv.m3u8

//接下来是漫长的等待...  
//ffmpeg正在将mtv.mp4切成一个个很小的ts文件，并生成一个mtv.m3u8的索引文件。
//编码完成以后
Hmily$ ls 
mtv.mp4 	mtv.m3u8    mtv12.ts	mtv19.ts	mtv25.ts	
mtv4.ts 	mtv13.ts	mtv2.ts		mtv26.ts	mtv5.ts
mtv14.ts	mtv20.ts	mtv27.ts	mtv6.ts     mtv30.ts
mtv0.ts		mtv15.ts	mtv21.ts	mtv28.ts	mtv7.ts
mtv1.ts		mtv16.ts	mtv22.ts	mtv29.ts	mtv8.ts
mtv10.ts	mtv17.ts	mtv23.ts	mtv3.ts		mtv9.ts
mtv11.ts	mtv18.ts	mtv24.ts	
{% endcodeblock %}

播放：
切片完成以后，将hls文件夹拷贝到/usr/local/var/www目录下。  
使用Safari播放：打开Safari，输入"http://localhost:9090/hls/mtv.m3u8"，回车。（这里localhost是本机IP地址：10.3.9.103）
iOS自带m3u8解码播放功能，打开Safari，输入"http://10.3.9.103:9090/hls/mtv.m3u8"也可以进行播放，或者在代码中使用UIWebView加载也是可以播放的。





### &emsp;&emsp;4.2、iOS代码推流测试  
#### &emsp;&emsp;4.2.1 添加iOS推流代码
添加LFLiveKit库
{% codeblock %}
#source 'https://github.com/CocoaPods/Specs.git'
#source <your private repo containing ijkplayer, FFmpeg4ijkplayer-ios-bin>

target ‘HLS’ do
platform :ios, '8.0'
pod 'SDWebImage', '~> 3.7.3'
pod 'LFLiveKit', '~> 2.5'
end
{% endcodeblock %}

添加OC代码  
LivePreviewController.h
{% codeblock lang:objc %}
//  Created by Hmily on 2016/12/5.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LivePreviewController : UIViewController

@end 
{% endcodeblock %}


LivePreviewController.m
{% codeblock lang:objc %}
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

//self.streamUrl = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream1555";//网上现的RTMP服务器，无需配置本地服务器
//self.streamUrl = @"rtmp://10.3.9.103:9090/rmspApp/133009";//自己搭建的本地RTMP服务器
self.streamUrl = @"http://10.3.9.103:9090/hls/133009";//HLS本地服务器
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
//stream.url = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream1555";

//stream.url = @"rtmp://10.3.9.103:1990/liveApp/abc";//RTMP
//stream.url = @"rtmp://192.168.2.107:1990/liveApp/abc";//RTMP
stream.url = @"http://10.3.9.103:1990/hls/abc";//HLS
//stream.url = @"http://192.168.2.107:1990/hls/abc";//HLS
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
case AVAuthorizationStatusRestricted:{
// 用户明确地拒绝授权，或者相机设备无法访问
break;
}
default:{
break;
}
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


@end

{% endcodeblock %}

#### &emsp;&emsp;4.2.2 模拟rtmp直播  
将代码中的self.streamUrl设置为
rtmp://10.3.9.10:9090/rmspApp/133009
{% codeblock lang:objc %}
//推流
//将代码中的self.streamUrl设置为rtmp://10.3.9.10:9090/rmspApp/133009
//直播会有多个直播室，这里随便弄一个编号133009模拟
self.streamUrl = @"rtmp://10.3.9.10:9090/rmspApp/133009";//自己搭建的本地服务器

//如果本地服务器还没有配置好，可以使用网上开源的一个地址进行测试
//self.streamUrl = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/133009";//开源的RTMP服务器(更改房间号就可以了)


//播放
//使用FLV播放
//File -> Open Network…
//RUL中输入  rtmp://10.3.9.10:9090/rmspApp/133009

//iOS使用ijkplayer播放
//NSString * videoUrl = @"rtmp://10.3.9.10:9090/rmspApp/133009";
//self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:videoUrl withOptions:nil];
//[_player prepareToPlay];
//[self.view addSubview:_player.view];
{% endcodeblock %}




#### &emsp;&emsp;4.2.2 模拟HLS直播
{% codeblock lang:objc %}
//推流
//将代码中的self.streamUrl设置为http://10.3.9.103:9088/hls/133009
//直播会有多个直播室，这里随便弄一个编号133009模拟
//注意拉流的端口号要与配置文件中的端口号一致（参见3.3）
self.streamUrl = @"http://10.3.9.103:9088/hls/133009";//HLS本地服务器


//播放
//使用FLV播放
//File -> Open Network…
//RUL中输入  http://10.3.9.103:9088/hls/133009.m3u8

//使用Safari播放
//在地址栏中输入  http://10.3.9.103:9088/hls/133009.m3u8

//iOS使用ijkplayer播放
//NSString * videoUrl = @"http://10.3.9.103:9088/hls/133009.m3u8";
//self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:videoUrl withOptions:nil];
//[_player prepareToPlay];
//[self.view addSubview:_player.view];
{% endcodeblock %}

代码事例请前往github下载：https://github.com/xudusheng/Http-Live-Streaming 。  
后面会陆陆续续把相关的理论知识补上，请继续关注。


