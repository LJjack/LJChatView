//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DemoSettings)

+ (void)saveExtraMessagesSetting:(BOOL)value;
+ (BOOL)extraMessagesSetting;

+ (void)saveLongMessageSetting:(BOOL)value;
+ (BOOL)longMessageSetting;

+ (void)saveEmptyMessagesSetting:(BOOL)value;
+ (BOOL)emptyMessagesSetting;

+ (void)saveSpringinessSetting:(BOOL)value;
+ (BOOL)springinessSetting;

+ (void)saveOutgoingAvatarSetting:(BOOL)value;
+ (BOOL)outgoingAvatarSetting;

+ (void)saveIncomingAvatarSetting:(BOOL)value;
+ (BOOL)incomingAvatarSetting;

+ (void)saveAccessoryButtonForMediaMessages:(BOOL)value;
+ (BOOL)accessoryButtonForMediaMessages;

@end
