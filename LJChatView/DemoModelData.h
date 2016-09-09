//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "JSQMessages.h"

/**
 *  This is for demo/testing purposes only. 
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */
NS_ASSUME_NONNULL_BEGIN
static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Jesse Squires";
static NSString * const kJSQDemoAvatarDisplayNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarDisplayNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarDisplayNameWoz = @"Steve Wozniak";

static NSString * const kJSQDemoAvatarIdSquires = @"053496-4509-289";
static NSString * const kJSQDemoAvatarIdCook = @"468-768355-23123";
static NSString * const kJSQDemoAvatarIdJobs = @"707-8956784-57";
static NSString * const kJSQDemoAvatarIdWoz = @"309-41802-93823";



@interface DemoModelData : NSObject

@property (strong, nonatomic) NSMutableArray<JSQMessage *> *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

- (void)addPhotoMediaMessageWithImagePath:(nonnull NSString *)imagePath;

- (void)addPhotoMediaMessageWithImage:(nonnull UIImage *)image;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

- (void)addVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage;

- (void)addAudioMediaMessageWithPath:(nonnull NSString *)audioPath audioTime:(NSInteger)audioTime;

@end
NS_ASSUME_NONNULL_END
