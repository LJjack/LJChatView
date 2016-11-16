//
//  LJLocationManager.m
//  testRoundPlace
//
//  Created by 刘俊杰 on 16/9/2.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJLocationManager.h"

#import <CoreLocation/CoreLocation.h>

@interface LJLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) LJLocationManagerDidUpdateBlock didUpdateBlock;

@property (nonatomic, copy) LJLocationManagerDidFailBlock didFailBlock;

@end

@implementation LJLocationManager

+ (instancetype)sharedManager {
    static LJLocationManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LJLocationManager alloc] init];
        [sharedInstance locationManager];
    });
    
    return sharedInstance;
}

- (BOOL)judgeCanLocation {
    BOOL isCan = NO;
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
        BOOL judgeState = state == kCLAuthorizationStatusAuthorizedWhenInUse || state == kCLAuthorizationStatusAuthorizedAlways;
        isCan = judgeState;
    } else {
        isCan = NO;
    }
    return isCan;
}

- (void)handelLocationWithDidUpdate:(LJLocationManagerDidUpdateBlock)didUpdateBlock
                            didFail:(LJLocationManagerDidFailBlock)didFailBlock {
    self.didUpdateBlock = didUpdateBlock;
    self.didFailBlock = didFailBlock;
    [self startUpdateLocation];//开启定位
}

- (void)startUpdateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

//根据经纬度反向地理编译出地址信息
-(void)reverseGeocodeCompletionHandler:(void(^)(CLPlacemark *placemark))completionHandler {
    [self reverseGeocodeWithLatitude:self.latitude longitude:self.longitude completionHandler:completionHandler];
}

//根据经纬度反向地理编译出地址信息
-(void)reverseGeocodeWithLatitude:(CGFloat)latitude
                        longitude:(CGFloat)longitude
                completionHandler:(void(^)(CLPlacemark *placemark))completionHandler {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        CLPlacemark *placemark = nil;
        if (!error && array.count) {
            placemark = [array objectAtIndex:0];
            
        }
        if (completionHandler) {
            completionHandler(placemark);
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
      didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    if (self.didUpdateBlock) {
        self.didUpdateBlock(location.coordinate.latitude,location.coordinate.longitude);
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (self.didFailBlock) {
        self.didFailBlock(error);
    }
}

#pragma mark - Getters And Setters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 1000;
        [_locationManager requestWhenInUseAuthorization]; //使用程序其间允许访问位置数据
        [self startUpdateLocation];//开启定位
    }
    return _locationManager;
}

@end
