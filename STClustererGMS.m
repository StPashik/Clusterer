//
//  STClustererGMS.m
//  avtospas
//
//  Created by StPashik on 15.09.13.
//  Copyright (c) 2013 l0gic. All rights reserved.
//

#import "STClustererGMS.h"
#import "STClusterMarker.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation STClustererGMS

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    _gridSize           = 25;
    
    tempArrayForCluster = [[NSMutableArray alloc] init];
    _markers            = [[NSMutableArray alloc] init];
    _markersInBounds    = [[NSMutableArray alloc] init];
    _clusters           = [[NSMutableArray alloc] init];
    
    return self;
}

- (id)initWithMapView:(GMSMapView *)mapView {
    self = [self init];
    if (!self)
        return nil;
    
    self.mapView = mapView;
    
    return self;
}

- (void)addMarker:(GMSMarker *)marker {
    [_markers addObject:marker];
    
    NSLog(@"%@", NSStringFromCGPoint([_mapView.projection pointForCoordinate:(marker.position)]));
}

- (void)removeAllMarkers {
    [_clusters removeAllObjects];
    [_markersInBounds removeAllObjects];
    [self.mapView clear];
}

- (void)clusterize {
    [self updateForChangeMap];
}

- (void)addFinalMarkers {
    for (int i = 0; i < _clusters.count; i++) {
        ((GMSMarker *)_clusters[i]).map = _mapView;
    }
}

- (void)updateForChangeMap {
    [self removeAllMarkers];
    
    for (int i = 0; i < _markers.count; i++) {
        GMSMarker *marker = (GMSMarker *)_markers[i];
        if (CGRectContainsPoint(_mapView.bounds, [_mapView.projection pointForCoordinate:(marker.position)])) {
            [_markersInBounds addObject:marker];
        }
    }
    
    CGRect gridCell = CGRectMake(0, 0, _gridSize, _gridSize);
    int horizontalCells = (int)(_mapView.bounds.size.width / _gridSize + 1);
    int verticalCells = (int)(_mapView.bounds.size.height / _gridSize + 1);
    
    for (int j = 0; j < verticalCells; j++) {
        for (int p = 0; p < horizontalCells; p++) {
            gridCell.origin.x = _gridSize * p;
            gridCell.origin.y = _gridSize * j;
            
            for (int l = 0; l < _markersInBounds.count; l++) {
                GMSMarker *marker = (GMSMarker *)_markersInBounds[l];
                if (CGRectContainsPoint(gridCell, [_mapView.projection pointForCoordinate:(marker.position)])) {
                    [tempArrayForCluster addObject:marker];
                    NSLog(@"Found Marker in cell vert:%d, hor:%d", j, p);
                }
            }
            
            if (tempArrayForCluster.count > 1) {
                [_markersInBounds removeObjectsInArray:tempArrayForCluster];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = [_mapView.projection coordinateForPoint:CGPointMake(gridCell.origin.x + (gridCell.size.width / 2), gridCell.origin.y + (gridCell.size.height / 2))];
                [_clusters addObject:marker];
            } else if (tempArrayForCluster.count == 1) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = ((GMSMarker *)tempArrayForCluster[0]).position;
                [_clusters addObject:marker];
            }
            
            [tempArrayForCluster removeAllObjects];
        }
//        NSLog(@"%d", _markersInBounds.count);
//        [_clusters addObject:_markersInBounds[j]];
        
        
    }
    
    [self addFinalMarkers];
}

@end
