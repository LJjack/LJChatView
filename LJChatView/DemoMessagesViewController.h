//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//


// Import all the things
#import "JSQMessages.h"

#import "DemoModelData.h"


@class DemoMessagesViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(DemoMessagesViewController *)vc;

@end




@interface DemoMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DemoModelData *demoData;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

@end
