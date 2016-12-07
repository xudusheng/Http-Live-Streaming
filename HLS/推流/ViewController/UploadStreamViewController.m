//
//  UploadStreamViewController.m
//  HLS
//
//  Created by Hmily on 2016/12/2.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "UploadStreamViewController.h"
#import "LFLivePreview.h"
@interface UploadStreamViewController ()

@end

@implementation UploadStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    LFLivePreview * livePreview = [[LFLivePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:livePreview];
    
}



@end
