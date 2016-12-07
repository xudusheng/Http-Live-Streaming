//
//  ViewController.m
//  HLS
//
//  Created by Hmily on 2016/11/30.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "ViewController.h"
#import "LiveVideoListViewController.h"
#import "CollectVideoViewController.h"
#import "BeautifyVideoViewController.h"
#import "UploadStreamViewController.h"
#import "LivePreviewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            
            break;
        case 1:{
            LiveVideoListViewController * videoVC = [[LiveVideoListViewController alloc] init];
            [self.navigationController pushViewController:videoVC animated:YES];
            break;
        }
        case 2:{
            CollectVideoViewController * collectVC = [[CollectVideoViewController alloc] init];
            [self.navigationController pushViewController:collectVC animated:YES];
            break;
        }
        case 3:{
            BeautifyVideoViewController * beautifyVC = [[BeautifyVideoViewController alloc] init];
            [self.navigationController pushViewController:beautifyVC animated:YES];
            break;
        }
        case 4:{
//            UploadStreamViewController * uploadVC = [[UploadStreamViewController alloc] init];
//            uploadVC.hidesTopBarWhenPushed = YES;
//            [self.navigationController pushViewController:uploadVC animated:YES];
            
            LivePreviewController * livePreVC = [[LivePreviewController alloc] init];
            livePreVC.hidesTopBarWhenPushed = YES;
            [self.navigationController pushViewController:livePreVC animated:YES];
            break;
        }
        default:
            break;
    }
}


@end
