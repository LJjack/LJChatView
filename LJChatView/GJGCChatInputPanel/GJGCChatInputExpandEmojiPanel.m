//
//  GJGCChatInputExpandEmojiPanel.m
//  GJGroupChat
//
//  Created by ZYVincent on 14-10-28.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJGCChatInputExpandEmojiPanel.h"
#import "GJGCChatInputExpandEmojiPanelPageItem.h"
#import "GJGCChatInputConst.h"
#import "GJGCChatInputExpandEmojiPanelMenuBar.h"
#import "GJGCChatInputExpandEmojiPanelGifPageItem.h"
#import "GJGCChatInputGifFloatView.h"
#import "UIView+GJCFViewFrameUitil.h"
#import "GJGCChatInputPanelStyle.h"

#define GJGCChatInputExpandEmojiPanelPageTag 239400

@interface GJGCChatInputExpandEmojiPanel ()<UIScrollViewDelegate,GJGCChatInputExpandEmojiPanelMenuBarDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic,assign)NSInteger pageCount;

@property (nonatomic,strong)UIPageControl *pageControl;

@property (nonatomic,strong)UIButton *sendButton;

@property (nonatomic,strong)GJGCChatInputExpandEmojiPanelMenuBar *menuBar;

@property (nonatomic,assign)BOOL isFinishLoadEmoji;

@end

@implementation GJGCChatInputExpandEmojiPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
     
        self.menuBar = [[GJGCChatInputExpandEmojiPanelMenuBar alloc]initWithDelegate:self];

        [self initSubViews];

        
    }
    return self;
}

- (instancetype)initWithFrameForCommentBarStyle:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.menuBar = [[GJGCChatInputExpandEmojiPanelMenuBar alloc]initWithDelegateForCommentBarStyle:self];
        
        [self initSubViews];
        
    }
    return self;
}

#pragma mark - 初始化
- (void)initSubViews
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.gjcf_width, self.gjcf_height - 44 - 20 - 6)];
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc]init];
    self.pageControl.frame = CGRectMake(0,0, 80, 20);
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    [self addSubview:self.pageControl];
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(pageIndexChange:) forControlEvents:UIControlEventValueChanged];
    
    UIImageView *bottomBarBack = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40.5)];
    bottomBarBack.backgroundColor = [GJGCChatInputPanelStyle mainBackgroundColor];
    bottomBarBack.userInteractionEnabled = YES;
    [self addSubview:bottomBarBack];
    
    UIImageView *seprateLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    seprateLine.backgroundColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    [bottomBarBack addSubview:seprateLine];
    
    [bottomBarBack addSubview:self.menuBar];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(0,0, 72, 40.5);
    self.sendButton.layer.cornerRadius = 3.f;
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[self imageForColor:[GJGCChatInputPanelStyle mainThemeColor] withSize:self.sendButton.gjcf_size] forState:UIControlStateNormal];
    [bottomBarBack addSubview:self.sendButton];
    [self.sendButton addTarget:self action:@selector(sendEmojiAction) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.gjcf_right = bottomBarBack.gjcf_width;
    
    
    bottomBarBack.gjcf_bottom = self.gjcf_height;
    self.pageControl.gjcf_bottom = bottomBarBack.gjcf_top - 8;
    self.pageControl.gjcf_centerX = self.scrollView.gjcf_width/2;
    
}

- (UIImage *)imageForColor:(UIColor*)aColor withSize:(CGSize)aSize
{
    if (!aColor) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, aSize.width, aSize.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)reserved
{
    for (UIView *subView in self.superview.subviews) {
        
        if ([subView.class isSubclassOfClass:[GJGCChatInputGifFloatView class]]) {
            
            [subView removeFromSuperview];
        }
    }
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.pageControl.currentPage = 0;
    
    self.sendButton.hidden = NO;
    
    [self loadEmojis];
    
    [self.menuBar selectAtIndex:0];
}

- (void)loadEmojis
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    NSArray *emojiArray = [NSArray arrayWithContentsOfFile:path];
    
    NSInteger pageItemCount = 20;
    
    /* 分割页面 */
    NSMutableArray *pagesArray = [NSMutableArray array];
    
    self.pageCount = emojiArray.count%pageItemCount == 0? emojiArray.count/pageItemCount:emojiArray.count/pageItemCount+1;
    self.pageControl.numberOfPages = self.pageCount;
    NSInteger pageLastCount = emojiArray.count%pageItemCount;
    
    for (int i = 0; i < self.pageCount; i++) {
        
        NSMutableArray *pageItemArray = [NSMutableArray array];
        
        
        if (i != self.pageCount - 1) {
            
            [pageItemArray addObjectsFromArray:[emojiArray subarrayWithRange:NSMakeRange(i*pageItemCount,pageItemCount)]];
            [pageItemArray addObject:@{@"删除":@"删除"}];
        }else{
            [pageItemArray addObjectsFromArray:[emojiArray subarrayWithRange:NSMakeRange(i*pageItemCount, pageLastCount)]];
        }
        
        [pagesArray addObject:pageItemArray];
    }
    
    /* 创建 */
    for (int i = 0; i < pagesArray.count ; i++) {
        
        NSArray *pageNamesArray = [pagesArray objectAtIndex:i];

        GJGCChatInputExpandEmojiPanelPageItem *pageItem = [[GJGCChatInputExpandEmojiPanelPageItem alloc]initWithFrame:CGRectMake(i*self.gjcf_width, 0, self.scrollView.gjcf_width, self.scrollView.gjcf_height) withEmojiNameArray:pageNamesArray];
        pageItem.panelIdentifier = self.panelIdentifier;
        
        pageItem.tag = GJGCChatInputExpandEmojiPanelPageTag + i;
        
        [self.scrollView addSubview:pageItem];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.pageCount * [UIScreen mainScreen].bounds.size.width, self.scrollView.gjcf_height);
}

- (void)loadEmojisWithSourceItem:(GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem*)item
{
    for (UIView *subView in self.superview.subviews) {
        
        if ([subView.class isSubclassOfClass:[GJGCChatInputGifFloatView class]]) {
            
            [subView removeFromSuperview];
        }
    }
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.pageControl.currentPage = 0;
    CGRect visiableRect = CGRectMake(0, 0, self.scrollView.gjcf_width, self.scrollView.gjcf_height);
    [self.scrollView scrollRectToVisible:visiableRect animated:NO];
    
    self.sendButton.hidden = !item.isNeedShowSendButton;
    
    switch (item.emojiType) {
        case GJGCChatInputExpandEmojiTypeSimple:
        {
            [self loadEmojis];
        }
            break;
//        case GJGCChatInputExpandEmojiTypeGIF:
//        {
//            [self loadGifEmojisWithListPath:item.emojiListFilePath];
//        }
            break;
        default:
            break;
    }
}

- (void)loadGifEmojisWithListPath:(NSString *)listPath
{
    NSArray *emojiArray = [NSArray arrayWithContentsOfFile:listPath];
    
    NSInteger pageItemCount = 8;
    
    /* 分割页面 */
    NSMutableArray *pagesArray = [NSMutableArray array];
    
    self.pageCount = emojiArray.count%pageItemCount == 0? emojiArray.count/pageItemCount:emojiArray.count/pageItemCount+1;
    self.pageControl.numberOfPages = self.pageCount;
    
    for (int i = 0; i < self.pageCount; i++) {
        
        NSMutableArray *pageItemArray = [NSMutableArray array];
        
        [pageItemArray addObjectsFromArray:[emojiArray subarrayWithRange:NSMakeRange(i*pageItemCount,pageItemCount)]];
        
        [pagesArray addObject:pageItemArray];
    }
    
    /* 创建 */
    for (int i = 0; i < pagesArray.count ; i++) {
        
        NSArray *pageNamesArray = [pagesArray objectAtIndex:i];
        
        GJGCChatInputExpandEmojiPanelGifPageItem  *pageItem = [[GJGCChatInputExpandEmojiPanelGifPageItem alloc]initWithFrame:CGRectMake(i*self.gjcf_width, 0, self.scrollView.gjcf_width, self.scrollView.gjcf_height) withEmojiNameArray:pageNamesArray];
        pageItem.panelIdentifier = self.panelIdentifier;
        pageItem.panelView = self.superview;
        
        pageItem.tag = GJGCChatInputExpandEmojiPanelPageTag + i;
        
        [self.scrollView addSubview:pageItem];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.pageCount * [UIScreen mainScreen].bounds.size.width, self.scrollView.gjcf_height);
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/scrollView.gjcf_width;
    self.pageControl.currentPage = page;
}

- (void)pageIndexChange:(UIPageControl *)sender
{
    CGRect visiableRect = CGRectMake(self.scrollView.gjcf_width * self.pageControl.currentPage, 0, self.scrollView.gjcf_width, self.scrollView.gjcf_height);
    [self.scrollView scrollRectToVisible:visiableRect animated:YES];
}

- (void)sendEmojiAction
{
    NSString *formateNoti = [GJGCChatInputConst panelNoti:GJGCChatInputExpandEmojiPanelChooseSendNoti formateWithIdentifier:self.panelIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:formateNoti object:nil];
}

#pragma mark - menuBarDelegate

- (void)emojiPanelMenuBar:(GJGCChatInputExpandEmojiPanelMenuBar *)bar didChoose:(GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem *)emojiSourceItem
{
    [self loadEmojisWithSourceItem:emojiSourceItem];
}

@end
