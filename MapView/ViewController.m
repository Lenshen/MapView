//
//  ViewController.m
//  MapView
//
//  Created by 远深 on 16/3/21.
//  Copyright © 2016年 himooo. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initMapView];
    [self initCLLocationManager];
}
-(void)initMapView
{
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;

    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;

}
-(void)initCLLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager requestAlwaysAuthorization];
    }else
    {
        NSLog(@"error");
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations firstObject];
    CLGeocoder *geoCoder =[[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placeMark = [placemarks firstObject];
        self.locationLabel.text = placeMark.name;
        
    }];
    NSLog(@"纬度=%f,经度=%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    CLLocationCoordinate2D pos = [currentLocation coordinate];

    [self showMapViewCoordinateRegion:pos];
    
   
}
//显示的范围视角和大头针功能。
-(void)showMapViewCoordinateRegion:(CLLocationCoordinate2D )locationcoordinat
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationcoordinat, 500, 500);
    
    MKCoordinateRegion region1 = [_mapView regionThatFits:region];
    [_mapView setRegion:region1 animated:YES];
    
   
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    userLocation.title = @"杭州";
[mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
