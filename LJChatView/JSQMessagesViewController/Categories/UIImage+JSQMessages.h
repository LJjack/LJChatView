//
//  Created by Jesse Squires
//  License
//  Copyright (c) 2014 Jesse Squires
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JSQMessages)

/**
 *  Creates and returns a new image object that is masked with the specified mask color.
 *
 *  @param maskColor The color value for the mask. This value must not be `nil`.
 *
 *  @return A new image object masked with the specified color.
 */
- (UIImage *)jsq_imageMaskedWithColor:(UIColor *)maskColor;
/**
 *  在图片中心添加一个小图片
 *
 *  @param smallImage 小图片
 *  
 *  @param size 生成图片的尺寸
 *
 *  @return 新和成的图片
 */
- (UIImage *)jsq_imageOnCenterAddSmallImage:(UIImage *)smallImage size:(CGSize)size;
/**
 *  @return The compact message bubble image. 
 *
 *  @discussion This is the default bubble image used by `JSQMessagesBubbleImageFactory`.
 */
+ (UIImage *)jsq_bubbleCompactImage;

/**
 *  @return 返回失败状态的图片
 */
+ (UIImage *)jsq_failedStateImage;

/**
 *  @return The standard share icon image.
 *
 *  @discussion This is the default icon for the message accessory button.
 */
+ (UIImage *)jsq_shareActionImage;

@end

NS_ASSUME_NONNULL_END
