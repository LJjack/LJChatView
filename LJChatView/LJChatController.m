//
//  LJChatController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatController.h"

#import "LJMessagesController.h"

#import "LJChatTopCell.h"
#import "LJChatCell.h"

#import "LJChatTopModel.h"

#import "LJChatSocialAPI.h"

#import "LJIMManagerListener.h"

#import "LJMessagesModel.h"

@interface LJChatController ()

@property (nonatomic, copy) NSArray<LJChatTopModel *> *topList;

@property (nonatomic, copy) NSArray<TIMConversation *> *dataList;

@end

@implementation LJChatController

- (void)dealloc {
    [self addOrRemveNotificationCenter:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addOrRemveNotificationCenter:YES];
    
    self.dataList =  [[LJIMManagerListener sharedInstance] getConversationList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.topList.count;
    }
    return self.dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LJChatTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJChatTopCell" forIndexPath:indexPath];
        cell.model = self.topList[indexPath.row];
        return cell;
    } else {
        LJChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJChatCell" forIndexPath:indexPath];
        cell.model = self.dataList[indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    } else {
        [LJIMManagerListener sharedInstance].chattingConversation = self.dataList[indexPath.row];
        [[LJIMManagerListener sharedInstance] openNewConversation];
        [self performSegueWithIdentifier:@"openMessage" sender:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44.f;
    } else {
        return 69.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.f;
    } else {
        return 12.f;
    }
}


#pragma mark - Getters

- (NSArray<LJChatTopModel *> *)topList {
    if (!_topList) {
        _topList = [LJChatTopModel topCellModelList];
    }
    return _topList;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openMessage"]) {
        NSIndexPath *indexPath = sender;
         LJMessagesController *msgC = segue.destinationViewController;
        LJMessagesModel *model = [LJMessagesModel sharedInstance];
        model.chatingConversation = self.dataList[indexPath.row];
        msgC.msgModel = model;
    }
}

#pragma mark - 

- (void)addOrRemveNotificationCenter:(BOOL)isAdd {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (isAdd) {
        [defaultCenter addObserver:self selector:@selector(handleUpdataUINotificationCenter) name:LJIMNotificationCenterUpdataChatUI object:nil];
    } else {
        [defaultCenter removeObserver:self name:LJIMNotificationCenterUpdataChatUI object:nil];
    }
    
}

- (void)handleUpdataUINotificationCenter {
    [self.tableView reloadData];
}

@end
