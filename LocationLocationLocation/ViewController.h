//
//  ViewController.h
//  LocationLocationLocation
//
//  Created by T. Andrew Binkowski on 2/22/15.
//  Copyright (c) 2015 The University of Chicago Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface ViewController : UIViewController <CLLocationManagerDelegate>
- (IBAction)tapDirections:(id)sender;
- (IBAction)tapSettings:(UIBarButtonItem *)sender;
- (IBAction)tapBeacon:(UIBarButtonItem *)sender;

/// Map Buttons
- (IBAction)tapShowLocation:(UIBarButtonItem *)sender;
- (IBAction)tapGoToDisney:(UIBarButtonItem *)sender;
- (IBAction)tapDropPins:(UIBarButtonItem *)sender;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

