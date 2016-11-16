//
//  LJChatController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatController.h"
#import "LJMessagesController.h"

#import "LJChatCell.h"

#import "LJMessagesModel.h"

#import "LJIMManagerListener.h"

@interface LJChatController ()

@property (nonatomic, copy) NSArray<TIMConversation *> *dataList;

@property (nonatomic, strong) NSIndexPath *selectedIndexPathForMenu;

@end

@implementation LJChatController

- (void)dealloc {
    [self addOrRemveNotificationCenter:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天列表";
    [self addOrRemveNotificationCenter:YES];
    self.tableView.tableFooterView = [UIView new];
    
    self.dataList =  [[LJIMManagerListener sharedInstance] getConversationList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickClosedBtn:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJChatCell" forIndexPath:indexPath];
    cell.model = self.dataList[indexPath.row];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[LJIMManagerListener sharedInstance] removeConversationListAtIndex:indexPath.row];
        self.dataList = [[LJIMManagerListener sharedInstance] getConversationList];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    return @[action];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [LJIMManagerListener sharedInstance].chattingConversation = self.dataList[indexPath.row];
    [[LJIMManagerListener sharedInstance] openNewConversation];
    
    LJMessagesController *msgC = [[LJMessagesController alloc] init];
    LJMessagesModel *model = [LJMessagesModel sharedInstance];
    model.chatingConversation = self.dataList[indexPath.row];
    msgC.msgModel = model;
    [self.navigationController pushViewController:msgC animated:YES];
}

#pragma mark - 通知中心

- (void)addOrRemveNotificationCenter:(BOOL)isAdd {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (isAdd) {
        [defaultCenter addObserver:self selector:@selector(handleUpdataUINotificationCenter) name:LJIMNotificationCenterUpdataChatUI object:nil];
    } else {
        [defaultCenter removeObserver:self name:LJIMNotificationCenterUpdataChatUI object:nil];
    }
}

- (void)handleUpdataUINotificationCenter {
    self.dataList = [[LJIMManagerListener sharedInstance] getConversationList];
    [self.tableView reloadData];
}

@end
