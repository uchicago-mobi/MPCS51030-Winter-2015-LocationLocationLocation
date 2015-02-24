//
//  ViewController.m
//  LocationLocationLocation
//
//  Created by T. Andrew Binkowski on 2/22/15.
//  Copyright (c) 2015 The University of Chicago Department of Computer Science. All rights reserved.
//

@import CoreLocation;
#import "ViewController.h"
#import "MyLocation.h"

#define METERS_PER_MILE 1609.344


@interface ViewController ()
@property (strong,nonatomic) CLLocationManager *locationManager;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Ask for permission (only one)
    //[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    self.mapView.hidden = NO;
}

///-----------------------------------------------------------------------------
#pragma mark - Button Actions
///-----------------------------------------------------------------------------
- (IBAction)tapDirections:(id)sender
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    MKPlacemark *disneyWorld = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(28.53806, -81.37944)
                                                     addressDictionary:nil];
    request.destination = [[MKMapItem alloc] initWithPlacemark:disneyWorld];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"[Error] %@", error);
            return;
        }
        
        MKRoute *route = [response.routes firstObject];
        for (MKRouteStep *step in route.steps) {
            NSLog(@"step:%@",step.instructions);
        }
    }];
}

- (IBAction)tapSettings:(UIBarButtonItem *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                UIApplicationOpenSettingsURLString]];
}

- (IBAction)tapBeacon:(UIBarButtonItem *)sender
{
    if (self.mapView.hidden == NO) {
//    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]
//                                                                            initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
//                                                                identifier:@"Estimotes"];
//    
//    [self.locationManager stopRangingBeaconsInRegion:region];
    self.mapView.hidden = YES;
    } else {
        self.mapView.hidden = NO;
    }
}


///-----------------------------------------------------------------------------
#pragma mark - GeoFencing
///-----------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    if ([region.description isEqualToString:@"Rio"]) {
        if (state == CLRegionStateInside) {
            NSLog(@"Already in Rio");
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Regions:%@",region);
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Goodbye";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter region:%@",region);
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Hello";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}



///-----------------------------------------------------------------------------
#pragma mark - Location Manager Delegate Methods
///-----------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        
        // Configure location manager
        [self.locationManager setDistanceFilter:kCLHeadingFilterNone];//]500]; // meters
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setHeadingFilter:kCLDistanceFilterNone];
        self.locationManager.activityType = CLActivityTypeFitness;
        
        // Start the location updating
        [self.locationManager startUpdatingLocation];
        
        // Start beacon monitoring
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]
                                                                                initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
                                                                    identifier:@"Estimotes"];
        [manager startRangingBeaconsInRegion:region];
        
        // Start region monitoring for Rio
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(-22.903,-43.2095);
        CLCircularRegion *bregion = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                                      radius:100
                                                                  identifier:@"Rio"];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        [self.locationManager startMonitoringForRegion:bregion];
        
        
        // Show map
        self.mapView.showsUserLocation = YES;
        self.mapView.showsPointsOfInterest = YES;
        
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                        message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Wrong location status");
    }
}


///-----------------------------------------------------------------------------
#pragma mark - Beacon Ranging
///-----------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *beacon = [beacons firstObject];
        if (CLProximityUnknown == beacon.proximity) return;
        
        //NSLog(@"Beacons:%@",beacon);
        switch (beacon.major.intValue) {
            case 16650:
                self.view.backgroundColor = [UIColor blueColor];
                break;
            case 48869:
                self.view.backgroundColor = [UIColor purpleColor];
                break;
            case 13602:
                self.view.backgroundColor = [UIColor greenColor];
                break;
            default:
                self.view.backgroundColor = [UIColor whiteColor];
                break;
        }
        
    }
}

///-----------------------------------------------------------------------------
#pragma mark - Map Kit Button
///-----------------------------------------------------------------------------
- (IBAction)tapShowLocation:(UIBarButtonItem *)sender
{
    CLLocation *userLoc = self.mapView.userLocation.location;
    [self.mapView setCenterCoordinate:userLoc.coordinate animated:YES];
}

- (IBAction)tapGoToDisney:(UIBarButtonItem *)sender {
    
    // Set the initial position of the map
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 28.53806;
    zoomLocation.longitude = -81.37944;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10*METERS_PER_MILE, 10*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (IBAction)tapDropPins:(UIBarButtonItem *)sender {
    // Remove existing
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    
    // Add some new pins
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = 28.53806;
    coordinates.longitude = -81.37944;
    MyLocation *annotation = [[MyLocation alloc] initWithName:@"Disney World" address:@"Orlando" coordinate:coordinates];
    [self.mapView addAnnotation:annotation];
    
    // Add another point
    CLLocationCoordinate2D coordinates2;
    coordinates2.latitude = 41.7897563;
    coordinates2.longitude = -87.5997711;
    MyLocation *annotation2 = [[MyLocation alloc] initWithName:@"The University of Chicago" address:@"Chicago" coordinate:coordinates2];
    [self.mapView addAnnotation:annotation2];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"MyLocation";
    
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MyLocation *location = (MyLocation *) annotation;
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:location reuseIdentifier:identifier];
        } else {
            annotationView.annotation = location;
        }
        
        // Set the pin properties
        annotationView.animatesDrop = YES;
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        // Show Mickey
        if ([location.title isEqualToString:@"Disney World"]) {
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Mickey"]];
        } else {
            // Since we are reusing cells we need to nil out the inmage
            annotationView.leftCalloutAccessoryView = nil;
        }
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"%@ %@",view,control);
}

@end
