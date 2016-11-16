//
//  LJGoodsMediaItem.m
//  BJHybrid
//
//  Created by 刘俊杰 on 16/10/24.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJGoodsMediaItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import <UIImageView+WebCache.h>

@interface LJGoodsMediaItem ()

@property (nonatomic, strong) UIView *cachedView;

@end

@implementation LJGoodsMediaItem

- (instancetype)initWithModel:(LJGoodsModel *)model {
    if (self = [super init]) {
        _model = model;
        _cachedView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews {
    [super clearCachedMediaViews];
    _cachedView = nil;
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedView = nil;
}

- (void)setModel:(LJGoodsModel *)model {
    _model = model;
    [self clearCachedMediaViews];
}

#pragma mark - JSQMessageMediaData protocol

- (CGSize)mediaViewDisplaySize {
    if (self.model.type == LJGoodsModelTypeProduct) {
        return CGSizeMake(kScreenWidth * 0.74, 95);
    } else if (self.model.type == LJGoodsModelTypeOrderInfo) {
        return CGSizeMake(kScreenWidth * 0.74, 140);
    }
    return [super mediaViewDisplaySize];
}

- (UIView *)mediaView {
    
    if (!self.cachedView && self.model) {
        CGSize size = [self mediaViewDisplaySize];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
        view.clipsToBounds = YES;
        view.backgroundColor = [UIColor whiteColor];
        
        if (self.model.type == LJGoodsModelTypeOrderInfo) {
            UILabel *orderLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, size.width - 20, 20)];
            orderLable.textColor = kBJRGB(84, 84, 84);
            orderLable.font = [UIFont systemFontOfSize:15.];
            orderLable.text = [NSString stringWithFormat:@"订单编号:%@", self.model.orderNo];
            [view addSubview:orderLable];
            
            UIImageView *prevView;
            NSInteger imageCount = 2;
            if (self.model.pictures.count < 2) {
                imageCount = self.model.pictures.count;
            }
            for (NSInteger i = 0; i < imageCount; ++i) {
                NSString *url = self.model.pictures[i];
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:url]];
                CGFloat imageX = 10;
                if (prevView) {
                    imageX = CGRectGetMaxX(prevView.frame) + 10;
                }
                imgView.frame = CGRectMake(imageX, CGRectGetMaxY(orderLable.frame) + 8, 60, 60);
                [view addSubview:imgView];
                prevView = imgView;
            }
            
            CGFloat totalX =CGRectGetMaxX(prevView.frame) + 10;
            UILabel *totalLable = [[UILabel alloc] initWithFrame: CGRectMake(totalX, CGRectGetMidY(prevView.frame) - 10, size.width - totalX - 5, 20)];
            totalLable.textColor = kBJRGB(139, 139, 139);
            totalLable.font = [UIFont systemFontOfSize:13.];
            totalLable.text = [NSString stringWithFormat:@"共%@件商品", self.model.orderCount];
            [view addSubview:totalLable];
            
            UILabel *summaryLable = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(prevView.frame) + 8, 0, 20)];
            
            NSString *totalPich = [NSString stringWithFormat:@"%@",self.model.orderTotal];
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"合计：%@(含运费%@)", totalPich, self.model.fee]];
            [attrStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.],NSForegroundColorAttributeName : kBJRGB(84, 84, 84)} range:NSMakeRange(0, 3)];
            
            [attrStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.],NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(3, 1 + totalPich.length)];
            
            [attrStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.],NSForegroundColorAttributeName:kBJRGB(84, 84, 84)} range:NSMakeRange(4 + totalPich.length, attrStr.length - 4 - totalPich.length)];
            summaryLable.attributedText = attrStr;
            [summaryLable sizeToFit];
            [view addSubview:summaryLable];
            
            CGFloat stateX = CGRectGetMaxX(summaryLable.frame) + 10;
            UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(stateX, CGRectGetMinY(summaryLable.frame), size.width - stateX - 5, 20)];
            stateLabel.textColor = [UIColor redColor];
            stateLabel.font = [UIFont systemFontOfSize:13.];
            stateLabel.text = self.model.orderStatus;
            [view addSubview:stateLabel];
        } else if (self.model.type == LJGoodsModelTypeProduct) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
            [imgView sd_setImageWithURL:[NSURL URLWithString:self.model.picture]];
            [view addSubview:imgView];
            
            CGFloat introX = CGRectGetMaxX(imgView.frame) + 10;
            UILabel *introLable = [[UILabel alloc] initWithFrame:CGRectMake(introX, 10, size.width - introX - 10, 40)];
            introLable.numberOfLines = 2;
            introLable.font = [UIFont systemFontOfSize:13.];
            introLable.textColor = kBJRGB(127, 127, 127);
            introLable.text = self.model.goodsName;
            [view addSubview:introLable];
            
            NSString *priceStr = [NSString stringWithFormat:@"%@",self.model.price];
            
            UILabel *priceLable = [[UILabel alloc] initWithFrame:CGRectMake(introX, CGRectGetMaxY(introLable.frame) + 10, 0, 20)];
            priceLable.text = priceStr;
            priceLable.font = [UIFont systemFontOfSize:15.];
            priceLable.textColor = kBJRGB(232, 95, 78);
            [priceLable sizeToFit];
            [view addSubview:priceLable];
            
            UILabel *sellOutLable = [[UILabel alloc] init];
            sellOutLable.textAlignment = NSTextAlignmentRight;
            sellOutLable.text = [[NSString alloc] initWithFormat:@"已售:%@件",self.model.salesVolume];
            sellOutLable.font = [UIFont systemFontOfSize:15.];
            sellOutLable.textColor = kBJRGB(159, 159, 159);
            CGFloat width = [sellOutLable sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)].width;
            
            CGRect sellOutFrame = CGRectMake(size.width - 10 - width, CGRectGetMidY(priceLable.frame), width, 20);
            sellOutLable.frame = sellOutFrame;
            [view addSubview:sellOutLable];
        }
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedView = view;
    }
    
    return _cachedView;
}

- (NSUInteger)mediaHash {
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return super.hash ^ self.model.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: goods=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.model, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(model))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.model forKey:NSStringFromSelector(@selector(model))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    LJGoodsMediaItem *copy = [[LJGoodsMediaItem allocWithZone:zone] initWithModel:self.model];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
