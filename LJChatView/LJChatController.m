//
//  LJChatController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatController.h"

#import "LJChatTopCell.h"
#import "LJChatCell.h"

#import "LJChatTopModel.h"

@interface LJChatController ()

@property (nonatomic, copy) NSArray<LJChatTopModel *> *topList;

@end

@implementation LJChatController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return 8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LJChatTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJChatTopCell" forIndexPath:indexPath];
        cell.model = self.topList[indexPath.row];
        return cell;
    } else {
        LJChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJChatCell" forIndexPath:indexPath];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 69;
    }
}


#pragma mark - Getters

- (NSArray<LJChatTopModel *> *)topList {
    if (!_topList) {
        _topList = [LJChatTopModel topCellModelList];
    }
    return _topList;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
