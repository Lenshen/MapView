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
    self.mapView.mapType = MKMapTypeHybrid;
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
    CLLocationCoordinate2D sportsAuthorityField = CLLocationCoordinate2DMake(30.747747, 120.658671);
    [self findDirectionsFrom:currentLocation.coordinate t0:sportsAuthorityField];
    
   
}
//显示的范围视角。
-(void)showMapViewCoordinateRegion:(CLLocationCoordinate2D )locationcoordinat
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationcoordinat, 200, 200);
    
    MKCoordinateRegion region1 = [_mapView regionThatFits:region];
    [_mapView setRegion:region1 animated:YES];
    
   
}
-(void)findDirectionsFrom:(CLLocationCoordinate2D )sourcesCoordination
                       t0:(CLLocationCoordinate2D )destinationCoordination
{
    MKPlacemark *sourcesPlaceMark = [[MKPlacemark alloc]initWithCoordinate:sourcesCoordination addressDictionary:nil];
    MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:sourcesPlaceMark];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordination addressDictionary:nil];
    MKMapItem *destinationMapItem = [[MKMapItem alloc]initWithPlacemark:destinationPlacemark];
    [self findDirectionsFrom:sourceMapItem to:destinationMapItem];
}
-(void)findDirectionsFrom:(MKMapItem *)sources to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = sources;
    request.destination = destination;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error");
        }else
        {
            [self showDirectionsOnMap:response];
        }
    }];
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[ MKPolylineRenderer alloc]initWithOverlay:overlay  ];
        renderer.lineWidth = 3;
        renderer.strokeColor = [UIColor redColor];
        return renderer;
    }
    else
    {
        return nil;
    }
    
}

-(void)showDirectionsOnMap:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes) {
        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
    }
    [self.mapView addAnnotation:response.source.placemark];
    [self.mapView addAnnotation:response.destination.placemark];
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
[mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
