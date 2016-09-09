//
//  GJGCIconSeprateImageView.m
//  GJGroupChat
//
//  Created by ZYVincent on 14-12-16.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJGCIconSeprateImageView.h"

@implementation GJGCIconSeprateImageView


- (void)drawRect:(CGRect)rect {
    
    if (self.image) {
        [self.image drawInRect:rect];
    }
}

- (void)setImage:(UIImage *)image
{
    if (_image == image) {
        return;
    }
    _image = nil;
    _image = image;
    
    [self setNeedsDisplay];
}


@end
