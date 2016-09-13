//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#import "DemoMessagesViewController.h"
#import "JSQMessagesViewAccessoryButtonDelegate.h"
#import "UIView+GJCFViewFrameUitil.h"
#import "GJGCChatInputPanel.h"
#import "GJCFAudioPlayer.h"
#import "NSString+LJEmojiParser.h"

#import <TZImagePickerController/TZImagePickerController.h>

#import <TZImagePickerController/TZImageManager.h>
#import <TZImagePickerController/TZVideoPlayerController.h>

#import "UIImage+LJVideo.h"
#import "LJRecordVideoView.h"
#import "LJFullVideoView.h"

#define GJCFSystemScreenHeight [UIScreen mainScreen].bounds.size.height
#define GJCFSystemScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DemoMessagesViewController ()<JSQMessagesViewAccessoryButtonDelegate, GJGCChatInputPanelDelegate , TZImagePickerControllerDelegate, GJCFAudioPlayerDelegate, LJRecordVideoViewDelegate>

@property (strong, nonatomic) GJGCChatInputPanel *inputPanel;

@property (nonatomic, strong) GJCFAudioPlayer *audioPlayer;//播放器

@property (nonatomic, assign) JSQAudioMediaItem *audioMediaOldItem;

@property (nonatomic, assign) JSQAudioMediaItem *audioMediaNewItem;

@property (nonatomic, strong) GJCFAudioModel *currentRecordFile;

@end

@implementation DemoMessagesViewController

#pragma mark - View lifecycle

- (void)dealloc {
    [self.inputPanel removeObserver:self forKeyPath:@"frame"];
}

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"JSQMessages";
    [self jsq_configureMessagesInputPanel];
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];
    
    /* 语音播放工具 */
    self.audioPlayer = [[GJCFAudioPlayer alloc]init];
    self.audioPlayer.delegate = self;
    
    /* 观察录音工具开始录音 */
//    NSString *formateNoti = [GJGCChatInputConst panelNoti:GJGCChatInputPanelBeginRecordNoti formateWithIdentifier:self.inputPanel.panelIndentifier];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeChatInputPanelBeginRecord:) name:formateNoti object:nil];
    
    
    /**
     *  Set up message accessory button delegate and configuration
     */
    self.collectionView.accessoryDelegate = self;

    
    self.showLoadEarlierMessagesHeader = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(receiveMessagePressed:)];

    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];

	
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
//    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}

//========================   输入键盘工具 开始  ================================

- (void)jsq_configureMessagesInputPanel {
    CGFloat originY = 0;
    /* 输入面板 */
    self.inputPanel = [[GJGCChatInputPanel alloc] initWithPanelDelegate:self];
    self.inputPanel.frame = (CGRect){0,GJCFSystemScreenHeight - self.inputPanel.inputBarHeight-originY,GJCFSystemScreenWidth,self.inputPanel.inputBarHeight+216};

    __weak typeof(self) weakSelf = self;
    [self.inputPanel configInputPanelKeyboardFrameChange:^(GJGCChatInputPanel *panel,CGRect keyboardBeginFrame, CGRect keyboardEndFrame, NSTimeInterval duration,BOOL isPanelReserve) {
        /* 不要影响其他不带输入面板的系统视图对话 */
        if (panel.hidden) {
            return ;
        }
        
        [UIView animateWithDuration:duration animations:^{
            CGFloat viewHeight = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight - originY - keyboardEndFrame.size.height;
            if (keyboardEndFrame.origin.y == GJCFSystemScreenHeight) {
                weakSelf.collectionView.transform = CGAffineTransformIdentity;
                if (isPanelReserve) {
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight  - originY;
                } else {
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - 216 - weakSelf.inputPanel.inputBarHeight - originY;
                    weakSelf.collectionView.transform = CGAffineTransformMakeTranslation(0, - 216);
                }
                
            } else {
                weakSelf.inputPanel.gjcf_top = viewHeight;
                weakSelf.collectionView.transform = CGAffineTransformMakeTranslation(0, keyboardEndFrame.origin.y - GJCFSystemScreenHeight);
            }
        }];
    }];

    [self.inputPanel configInputPanelRecordStateChange:^(GJGCChatInputPanel *panel, BOOL isRecording) {
        NSLog(@"=======");
        if (isRecording) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                [weakSelf stopPlayCurrentAudio];
                
                
                
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
    }];

    [self.inputPanel configInputPanelInputTextViewHeightChangedBlock:^(GJGCChatInputPanel *panel, CGFloat changeDelta) {
        panel.gjcf_top = panel.gjcf_top - changeDelta;

        panel.gjcf_height = panel.gjcf_height + changeDelta;

    }];

    /* 动作变化 */
    [self.inputPanel setActionChangeBlock:^(GJGCChatInputBar *inputBar, GJGCChatInputBarActionType toActionType) {
        [weakSelf inputBar:inputBar changeToAction:toActionType];
    }];
    [self.view addSubview:self.inputPanel];

    /* 观察输入面板变化 */
    [self.inputPanel addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 恢复输入面板到初始状态

- (void)reserveChatInputPanelState
{
    /* 收起输入键盘 */
    if (self.inputPanel.isFullState) {
        
        CGFloat originY = 0;
        
        self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
        
        self.collectionView.transform = CGAffineTransformIdentity;
        
        [self.inputPanel reserveState];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if ([self.inputPanel isInputTextFirstResponse]) {
        
        [self.inputPanel inputBarRegsionFirstResponse];
        
    }
    [UIView animateWithDuration:0.26 animations:^{
        [self reserveChatInputPanelState];
    }];
    
}

#pragma mark - 属性变化观察
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] && object == self.inputPanel) {

        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];

        CGFloat originY = 0;

        //50.f 高度是输入条在底部的时候显示的高度，在录音状态下就是50
        if (newFrame.origin.y < GJCFSystemScreenHeight - 50.f - originY) {

            self.inputPanel.isFullState = YES;

        }else{

            self.inputPanel.isFullState = NO;
        }
    }
}


#pragma mark - 输入动作变化

- (void)inputBar:(GJGCChatInputBar *)inputBar changeToAction:(GJGCChatInputBarActionType)actionType
{
    CGFloat originY = 0;

    switch (actionType) {
        case GJGCChatInputBarActionTypeRecordAudio:
        {
            if (self.inputPanel.isFullState) {

                [UIView animateWithDuration:0.26 animations:^{

                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
                    self.collectionView.transform = CGAffineTransformIdentity;
                }];
            }
        }
            break;
        case GJGCChatInputBarActionTypeChooseEmoji:
        case GJGCChatInputBarActionTypeExpandPanel:
        {
            if (!self.inputPanel.isFullState) {

                [UIView animateWithDuration:0.26 animations:^{

                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - (self.inputPanel.inputBarHeight + 216 + originY);
                    self.collectionView.transform = CGAffineTransformMakeTranslation(0, -(216 + originY));
                }];
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - GJGCChatInputPanelDelegate

- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendTextMessage:(NSString *)text
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[self.collectionView.dataSource senderId]
                                             senderDisplayName:[self.collectionView.dataSource senderDisplayName]
                                                          date:[NSDate date]
                                                          text:text];
    
    [self.demoData.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];

}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didFinishRecord:(GJCFAudioModel *)audioFile
{
    self.currentRecordFile = audioFile;
    
    [self.demoData addAudioMediaMessageWithPath:audioFile.localStorePath audioTime:audioFile.duration];
    [self finishSendingMessage];
}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didChooseMenuAction:(GJGCChatInputMenuPanelActionType)actionType
{
    switch (actionType) {
        case GJGCChatInputMenuPanelActionTypePhotoLibrary:
        {
            [self openNativePhotoLibrary];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeCamera:
        {
            [self shootCamera];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeSmallVideo:
        {
            [self shootSmallVideo];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeLocation:
        {
            [self obtainCurrentLocation];
        }
            break;
        default:
            break;
    }
}

//========================   输入键盘工具 结束  ================================

//打开本地图片和视频
- (void)openNativePhotoLibrary {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    
    //四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    for (UIImage *image in photos) {
//        [self.demoData addPhotoMediaMessageWithImage:image];
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];

        JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                       displayName:kJSQDemoAvatarDisplayNameSquires
                                                             media:photoItem];
        [self.demoData.messages addObject:photoMessage];
        [self finishSendingMessage];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            photoItem.image = image;
            [self.collectionView reloadData];
        });
    }
    
    
    
}

// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    // 打开这段代码发送视频
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //         导出完成，在这里写上传代码，通过路径或者通过NSData上传
        [weakSelf.demoData addVideoMediaMessageWithVideoPath:outputPath showImage:coverImage];
        [weakSelf finishSendingMessage];
    }];

}
//拍摄图片
- (void)shootCamera {
    
}
//拍小视频
- (void)shootSmallVideo {
    // 隐藏键盘
    [self reserveChatInputPanelState];
    
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (videoStatus == 	AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied) {
            // 没有权限
//            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
            return;
        }
        
        AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioStatus == 	AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied) {
            // 没有权限
//            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-麦克风\"中允许访问麦克风。" cancel:@"确定"];
            return;
        }
        __weak typeof(self) weakSelf = self;
        if (videoStatus == AVAuthorizationStatusNotDetermined) {
            //请求相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if(granted) {
                    AVAuthorizationStatus audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                    if (audio == AVAuthorizationStatusNotDetermined) {
                        //请求麦克风权限
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (granted) {
                                    [weakSelf addRecordVideoView];
                                }
                            });
                        }];
                    } else {//这里一定是有麦克风权限了
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf addRecordVideoView];
                        });
                    }
                }
                
            }];
        } else {//这里一定是有相机权限了
            if (audioStatus == AVAuthorizationStatusNotDetermined) {
                //请求麦克风权限
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            [weakSelf addRecordVideoView];
                        }
                    });
                    
                }];
            } else {//这里一定是有麦克风权限了
                [weakSelf addRecordVideoView];
            }
            
        }
    }
}

- (void)addRecordVideoView {
    CGFloat selfWidth  = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    LJRecordVideoView *videoView = [[LJRecordVideoView alloc] initWithFrame:CGRectMake(0, selfHeight/3, selfWidth, selfHeight * 2/3)];
    videoView.delegate = self;
    [self.view addSubview:videoView];
}
#pragma mark - LJRecordVideoViewDelegate

- (void)recordVideoViewTouchUpDone:(NSString *)savePath {
    
    
    NSError *err = nil;
    NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:&err];
    //文件最大不超过28MB
    if(data.length < 28 * 1024 * 1024) {
//        IMAMsg *msg = [IMAMsg msgWithVideoPath:savePath];
//        [self sendMsg:msg];
        UIImage *showImage = [UIImage lj_imageVideoCaptureVideoPath:savePath];

        UISaveVideoAtPathToSavedPhotosAlbum(savePath, nil, nil, nil);
        [self.demoData addShortVideoMediaMessageWithVideoPath:savePath showImage:showImage];
        [self finishSendingMessage];
        NSLog(@"==== %@", savePath);
    } else {
//        [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
        NSLog(@"发送的文件过大");
    }
}

//获取当前位置
- (void)obtainCurrentLocation {
    __weak typeof(self) weakSelf = self;
    [self.demoData addLocationMediaMessageCompletion:^{
        [weakSelf finishSendingMessage];
    }];
    
}

#pragma mark - 播放音频

- (void)startPlayCurrentAudio {
    
    [self stopOldPlayAudio];
    
    GJCFAudioModel *audioModel = [[GJCFAudioModel alloc] init];
    audioModel.localStorePath = self.audioMediaNewItem.audioPath;
    [self.audioPlayer playAudioFile:audioModel];
    [self.audioPlayer play];
    [self.audioMediaNewItem startAudioAnimating];
    self.audioMediaOldItem = self.audioMediaNewItem;
}

- (void)stopOldPlayAudio {
    if (self.audioMediaOldItem && [self.audioMediaOldItem isAudioAnimating]) {
        [self.audioPlayer stop];
        [self.audioMediaOldItem stopAudioAnimating];
        self.audioMediaOldItem = nil;
    }
    
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didOccusError:(NSError *)error {
    [self stopOldPlayAudio];
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didFinishPlayAudio:(GJCFAudioModel *)audioFile {
    [self stopOldPlayAudio];
}

#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    /**
     *  Display custom menu actions for cells.
     */
    UIMenuController *menu = [notification object];
    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
    
    [super didReceiveMenuWillShowNotification:notification];
}


#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[LJShortVideoMediaItem class]]) {
                LJShortVideoMediaItem *videoItemCopy = [((LJShortVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.videoPath copy];
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.videoPath = nil;
                
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = @(audioItemCopy.audioTime);
//
//                /**
//                 *  Reset audio item to simulate "downloading" the audio
//                 */
                audioItemCopy.audioTime = 10;
                audioItemCopy.audioPath = [[NSBundle mainBundle] pathForResource:@"jsq_messages_sample" ofType:@"m4a"];
//
                newMediaData = audioItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */

        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];

        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[LJShortVideoMediaItem class]]) {
                    ((LJShortVideoMediaItem *)newMediaData).videoPath = newMediaAttachmentCopy;
                    
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                    ((JSQAudioMediaItem *)newMediaData).audioTime = [newMediaAttachmentCopy integerValue];
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */

    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.demoData.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return kJSQDemoAvatarIdSquires;
}

- (NSString *)senderDisplayName {
    return kJSQDemoAvatarDisplayNameSquires;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        
    }
    else {
        
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
    }

    cell.accessoryButton.hidden = ![self shouldShowAccessoryButtonForMessage:msg];
    
    return cell;
}

- (BOOL)shouldShowAccessoryButtonForMessage:(id<JSQMessageData>)message
{
    return [message isMediaMessage];
}


#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }

    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }

    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    
    if ([message.media isKindOfClass:[JSQAudioMediaItem class]]) {
        self.audioMediaNewItem = (JSQAudioMediaItem *)message.media;
        [self startPlayCurrentAudio];
        
        NSLog(@"点击音频!");
    } else if ([message.media isKindOfClass:[LJShortVideoMediaItem class]]) {
        NSLog(@"点击 微 视频!");
        LJShortVideoMediaItem *videoMediaItem = (LJShortVideoMediaItem *)message.media;
        LJFullVideoView *fullVideoView = [[LJFullVideoView alloc] initWithVideoPath:videoMediaItem.videoPath coverImage:videoMediaItem.aFrameImage];
        [fullVideoView showFullVideoView];
        
    } else if ([message.media isKindOfClass:[LJVideoMediaItem class]]) {
        NSLog(@"点击视频!");
    } else if ([message.media isKindOfClass:[JSQLocationMediaItem class]]) {
        NSLog(@"点击地图!");
    } else if ([message.media isKindOfClass:[JSQPhotoMediaItem class]]) {
        NSLog(@"点击图片!");
    }  else  {
        NSLog(@"点击文字!");
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods
//发送和接受状态的代理
- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}

@end
