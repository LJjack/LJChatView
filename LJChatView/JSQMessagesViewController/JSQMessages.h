//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#ifndef JSQMessages_JSQMessages_h
#define JSQMessages_JSQMessages_h

#import "JSQMessagesViewController.h"

//  Views
#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"
#import "JSQMessagesTypingIndicatorFooterView.h"
#import "JSQMessagesLoadEarlierHeaderView.h"

//  Layout
#import "JSQMessagesBubbleSizeCalculating.h"
#import "JSQMessagesBubblesSizeCalculator.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesCollectionViewLayoutAttributes.h"
#import "JSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

//  Model
#import "JSQMessage.h"

#import "JSQMediaItem.h"
#import "JSQAudioMediaItem.h"
#import "JSQPhotoMediaItem.h"
#import "JSQLocationMediaItem.h"
#import "LJShortVideoMediaItem.h"//自己写的

#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesAvatarImage.h"

//  Protocols
#import "JSQMessageData.h"
#import "JSQMessageMediaData.h"
#import "JSQMessageAvatarImageDataSource.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessagesCollectionViewDataSource.h"
#import "JSQMessagesCollectionViewDelegateFlowLayout.h"
#import "JSQMessagesViewAccessoryButtonDelegate.h"

//  Factories
#import "JSQMessagesAvatarImageFactory.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "JSQMessagesTimestampFormatter.h"

//  Categories
#import "NSString+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"
#import "NSBundle+JSQMessages.h"

#endif
