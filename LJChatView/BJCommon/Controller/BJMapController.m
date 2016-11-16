//
//  BJMapController.m
//  BuJiong
//
//  Created by 刘俊杰 on 16/4/26.
//  Copyright © 2016年 BuJiong. All rights reserved.
//

#import "BJMapController.h"
#import <MapKit/MapKit.h>

@interface BJMapPinAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic,   copy) NSString *title;

@property (nonatomic,   copy) NSString *subtitle;

@end

@implementation BJMapPinAnnotation
@end

@interface BJMapController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation BJMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    if (!CLLocationCoordinate2DIsValid(self.location)) {
        //默认显示地点
        self.location = CLLocationCoordinate2DMake(40.71, -74.00);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)clickBackBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 添加地图控件
-(void)setupUI{
    [self.view addSubview:self.mapView];
    self.mapView.frame = self.view.bounds;
    
    [self.view addSubview:self.backBtn];
    self.backBtn.frame = CGRectMake(0, 20, 44, 44);
    
    //设置地图显示范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(_location, span);
    [_mapView setRegion:region animated:YES];
    
//    添加大头针
    [self addAnnotation];
}

#pragma mark 添加大头针
-(void)addAnnotation{
    BJMapPinAnnotation *annotation = [[BJMapPinAnnotation alloc] init];
    annotation.title = self.locTitle;
    annotation.subtitle = self.locSubtitle;
    annotation.coordinate = self.location;
    [_mapView addAnnotation:annotation];
}

#pragma mark - 地图控件代理方法

#pragma mark 更新用户位置，只要用户改变则调用此方法（包括第一次定位到用户位置）
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    BJLog(@"didUpdateUserLocation %@",userLocation);
}

#pragma mark - Getters And Setters

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        //设置代理
        _mapView.delegate = self;
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        //设置地图类型
        _mapView.mapType = MKMapTypeStandard;
    }
    return _mapView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"Navbar-back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

@end
