//
//  LJRecordVideoView.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/8/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJRecordVideoViewDelegate <NSObject>

@optional

- (void)recordVideoViewTouchUpDone:(NSString *)savePath;

@end

@interface LJRecordVideoView : UIImageView

@property (nonatomic, weak) id<LJRecordVideoViewDelegate> delegate;


@end
