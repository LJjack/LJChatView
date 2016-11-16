//
//  LJMessageHeaderView.m
//  BJHybrid
//
//  Created by 刘俊杰 on 16/10/24.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJMessageHeaderView.h"

#import <UIImageView+WebCache.h>

@interface LJMessageHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLable;

@property (weak, nonatomic) IBOutlet UILabel *sellOutLabel;

@property (weak, nonatomic) IBOutlet UIButton *sendLinkBtn;

@end

@implementation LJMessageHeaderView

+ (instancetype)headerView {
    return [[NSBundle mainBundle] loadNibNamed:@"LJMessageHeaderView" owner:self options:nil].firstObject;
}

+ (instancetype)headerViewWithModel:(LJGoodsModel *)model {
    LJMessageHeaderView *headerView = [self headerView];
    headerView.model = model;
    return headerView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sendLinkBtn.layer.borderColor = kBJRGB(232, 162, 79).CGColor;
    self.sendLinkBtn.layer.borderWidth = 0.5;
    self.sendLinkBtn.layer.cornerRadius = 5.;
    self.sendLinkBtn.layer.masksToBounds = YES;
}

- (IBAction)clickSendLink:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(messageHeaderView:didClickSendLinkBtn:)]) {
        [self.delegate messageHeaderView:self didClickSendLinkBtn:self.model];
    }
}
- (IBAction)handleTapGR:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(messageHeaderView:didClickSelf:)]) {
        [self.delegate messageHeaderView:self didClickSelf:self.model];
    }
    
}

- (void)setModel:(LJGoodsModel *)model {
    _model = model;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.picture]];
    self.titleLabel.text = model.goodsName;
    self.priceLable.text = [NSString stringWithFormat:@"%@",model.price];
    self.sellOutLabel.text = [NSString stringWithFormat:@"已售:%@件",model.salesVolume];
}

@end
