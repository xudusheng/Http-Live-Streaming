//
//  LiveVideoListViewController.m
//  HLS
//
//  Created by Hmily on 2016/11/30.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "LiveVideoListViewController.h"
#import "LiveVideoPlayerViewController.h"
#import "UIImageView+WebCache.h"
@interface LiveVideoListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSMutableArray * videoList;

@end

@implementation LiveVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoList = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 55;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    [self fetchVideoList];
}


#pragma mark 网络请求
- (void)fetchVideoList{
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURL * url = [NSURL URLWithString:@"http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1"];
    
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:nil];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSArray * lives = result[@"lives"];
                [self.videoList addObjectsFromArray:lives];
                [self.tableView reloadData];
            }];
        }
    }];
    
    [task resume];
}


#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _videoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary * creator = _videoList[indexPath.row][@"creator"];
    
//    "creator": {
//        //        "id": 721330,
//        //        "level": 61,
//        //        "gender": 0,
//        //        "nick": "LZ💃小祖宗 勿忘初心",
//        //        "portrait": "http://img2.inke.cn/MTQ4MDQyMTI0OTg2NiM3NTcjanBn.jpg"
//        //    },
    
    NSString * portrait = creator[@"portrait"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:portrait]];
    cell.textLabel.text = creator[@"nick"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * oneLive = _videoList[indexPath.row];
    
    LiveVideoPlayerViewController * playerVC = [[LiveVideoPlayerViewController alloc] init];
    playerVC.videoInfo = oneLive;
    [self.navigationController pushViewController:playerVC animated:YES];
    
}



@end
