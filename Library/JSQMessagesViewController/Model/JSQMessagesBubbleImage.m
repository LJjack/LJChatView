//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#import "JSQMessagesBubbleImage.h"

@implementation JSQMessagesBubbleImage

#pragma mark - Initialization

- (instancetype)initWithMessageBubbleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    NSParameterAssert(image != nil);
    NSParameterAssert(highlightedImage != nil);
    
    self = [super init];
    if (self) {
        _messageBubbleImage = image;
        _messageBubbleHighlightedImage = highlightedImage;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: messageBubbleImage=%@, messageBubbleHighlightedImage=%@>",
            [self class], self.messageBubbleImage, self.messageBubbleHighlightedImage];
}

- (id)debugQuickLookObject
{
    return [[UIImageView alloc] initWithImage:self.messageBubbleImage highlightedImage:self.messageBubbleHighlightedImage];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithMessageBubbleImage:[UIImage imageWithCGImage:self.messageBubbleImage.CGImage]
                                                        highlightedImage:[UIImage imageWithCGImage:self.messageBubbleHighlightedImage.CGImage]];
}

@end
