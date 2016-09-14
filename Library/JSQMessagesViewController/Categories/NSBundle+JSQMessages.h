//
//  Created by Jesse Squires
//  License
//  Copyright (c) 2014 Jesse Squires
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (JSQMessages)

/**
 *  @return The bundle for JSQMessagesViewController.
 */
+ (NSBundle *)jsq_messagesBundle;

/**
 *  @return The bundle for assets in JSQMessagesViewController.
 */
+ (NSBundle *)jsq_messagesAssetBundle;

/**
 *  Returns a localized version of the string designated by the specified key and residing in the JSQMessages table.
 *
 *  @param key The key for a string in the JSQMessages table.
 *
 *  @return A localized version of the string designated by key in the JSQMessages table.
 */
+ (nullable NSString *)jsq_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
