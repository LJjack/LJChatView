//
//  LJLocationMediaItem.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/21.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJLocationMediaItem.h"

#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MapKit/MapKit.h>

@interface LJLocationMediaItem ()

@property (nonatomic, strong) UIImage *cachedMapSnapshotImage;

@property (nonatomic, strong) UIImageView *cachedMapImageView;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation LJLocationMediaItem

- (void)clearCachedMediaViews {
    _cachedMapImageView = nil;
    
    [super clearCachedMediaViews];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
    
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
}

- (void)setLatitude:(double)latitude
          longitude:(double)longitude completionHandler:(void (^)())completion {
    
    _latitude = latitude;
    _longitude = longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    _coordinate = coordinate;
    BOOL isValid = CLLocationCoordinate2DIsValid(coordinate);
    NSAssert(isValid, @"location 不能为空");
    if (!isValid) return;
    
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    
    [self createMapViewSnapshotForCoordinate2D:coordinate
                          coordinateRegion:region
                     withCompletionHandler:completion];
}

#pragma mark - Map snapshot



- (void)createMapViewSnapshotForCoordinate2D:(CLLocationCoordinate2D)coordinate
                        coordinateRegion:(MKCoordinateRegion)region
                   withCompletionHandler:(void(^)())completion {
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.size = [self mediaViewDisplaySize];
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  if (snapshot == nil) {
                      NSLog(@"%s Error creating map snapshot: %@", __PRETTY_FUNCTION__, error);
                      return;
                  }
                  
                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                  CGPoint coordinatePoint = [snapshot pointForCoordinate:coordinate];
                  UIImage *image = snapshot.image;
                  
                  coordinatePoint.x += pin.centerOffset.x - (CGRectGetWidth(pin.bounds) / 2.0);
                  coordinatePoint.y += pin.centerOffset.y - (CGRectGetHeight(pin.bounds) / 2.0);
                  
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  [image drawAtPoint:CGPointZero];
                  [pin.image drawAtPoint:coordinatePoint];
                  self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                  UIGraphicsEndImageContext();
                  
                  if (completion) {
                      dispatch_async(dispatch_get_main_queue(), completion);
                  }
              }];
}


#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView {
    if (!CLLocationCoordinate2DIsValid(self.coordinate) || !self.cachedMapSnapshotImage) return nil;
    
    if (self.cachedMapImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedMapSnapshotImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMapImageView = imageView;
    }
    
    return self.cachedMapImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

- (NSString *)mediaDataType
{
    return (NSString *)kUTTypeURL;
}

- (id)mediaData {
    NSString *locationAsGoogleMapsString = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f&z=18&q=%%20", self.coordinate.latitude, self.coordinate.longitude ];
    NSURL *locationURL = [[NSURL alloc] initWithString:locationAsGoogleMapsString];
    return locationURL;
}


#pragma mark - NSObject

- (BOOL)isEqual:(LJLocationMediaItem *)locationItem {
    if (![super isEqual:locationItem]) return NO;
    
    return self.coordinate.latitude == locationItem.coordinate.latitude && self.coordinate.longitude == locationItem.coordinate.longitude;
}

- (NSUInteger)hash {
    return [super hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: latitude=%@ longitude=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], @(self.latitude), @(self.longitude), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        double latitude = [aDecoder decodeDoubleForKey:NSStringFromSelector(@selector(latitude))];
        double longitude = [aDecoder decodeDoubleForKey:NSStringFromSelector(@selector(longitude))];
        
        [self setLatitude:latitude longitude:longitude completionHandler:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.latitude forKey:NSStringFromSelector(@selector(latitude))];
    [aCoder encodeDouble:self.longitude forKey:NSStringFromSelector(@selector(longitude))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    LJLocationMediaItem *copy = [[LJLocationMediaItem allocWithZone:zone] init];
    [self setLatitude:self.latitude longitude:self.longitude completionHandler:nil];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
