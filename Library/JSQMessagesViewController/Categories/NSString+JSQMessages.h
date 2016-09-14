//
//  Created by Jesse Squires
//  License
//  Copyright (c) 2014 Jesse Squires
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JSQMessages)

/**
 *  @return A copy of the receiver with all leading and trailing whitespace removed.
 */
- (NSString *)jsq_stringByTrimingWhitespace;

@end

NS_ASSUME_NONNULL_END
