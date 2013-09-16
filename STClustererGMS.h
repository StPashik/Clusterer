//
//  STClustererGMS.h
//  avtospas
//
//  Created by StPashik on 15.09.13.
//  Copyright (c) 2013 l0gic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface STClustererGMS : NSObject {
    NSMutableArray *tempArrayForCluster;
}

@property (weak, readwrite, nonatomic) GMSMapView *mapView;
@property (strong, readonly, nonatomic) NSMutableArray *markers;
@property (strong, readonly, nonatomic) NSMutableArray *markersInBounds;
@property (strong, readonly, nonatomic) NSMutableArray *clusters;
@property (assign, readwrite, nonatomic) NSInteger gridSize;

- (id)initWithMapView:(GMSMapView *)map;
- (void)addMarker:(GMSMarker *)marker;
- (void)removeAllMarkers;
- (void)clusterize;
- (void)updateForChangeMap;

@end
