//
//  STClustererGMS.m
//  avtospas
//
//  Created by StPashik on 15.09.13.
//  Copyright (c) 2013 l0gic. All rights reserved.
//

#import "STClustererGMS.h"
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
//        обработчик видимых маркеров
//        if (CGRectContainsPoint(_mapView.bounds, [_mapView.projection pointForCoordinate:(marker.position)])) {
//            [_markersInBounds addObject:marker];
//        }
        
        [_markersInBounds addObject:marker];
    }
    
    for (int j = 0; j < _markersInBounds.count; j++) {
        [tempArrayForCluster addObject:(GMSMarker *)_markersInBounds[j]];
        for (int p = 0; p < _markersInBounds.count; p++) {
            if (![_markersInBounds[j] isEqual:_markersInBounds[p]]) {
                CGPoint point1 = [_mapView.projection pointForCoordinate:(((GMSMarker *)_markersInBounds[j]).position)];
                CGPoint point2 = [_mapView.projection pointForCoordinate:(((GMSMarker *)_markersInBounds[p]).position)];
                GMSMarker *marker = (GMSMarker *)_markersInBounds[p];
                if ([self checkDistance:point1 point2:point2]) {
                    [tempArrayForCluster addObject:marker];
                }
            }
        }
        
        if (tempArrayForCluster.count > 1) {
            [_markersInBounds removeObjectsInArray:tempArrayForCluster];
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            marker.position = [_mapView.projection coordinateForPoint:[self findMiddlePoint:tempArrayForCluster]];
            [_clusters addObject:marker];
        } else if (tempArrayForCluster.count == 1) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = ((GMSMarker *)tempArrayForCluster[0]).position;
            [_clusters addObject:marker];
        }
        
        [tempArrayForCluster removeAllObjects];
    }
    
//    Squer metod
    
//    CGRect gridCell = CGRectMake(0, 0, _gridSize, _gridSize);
//    int horizontalCells = (int)(_mapView.bounds.size.width / _gridSize + 1);
//    int verticalCells = (int)(_mapView.bounds.size.height / _gridSize + 1);
    
//    for (int j = 0; j < verticalCells; j++) {
//        for (int p = 0; p < horizontalCells; p++) {
//            gridCell.origin.x = _gridSize * p;
//            gridCell.origin.y = _gridSize * j;
//            
//            for (int l = 0; l < _markersInBounds.count; l++) {
//                GMSMarker *marker = (GMSMarker *)_markersInBounds[l];
//                if (CGRectContainsPoint(gridCell, [_mapView.projection pointForCoordinate:(marker.position)])) {
//                    [tempArrayForCluster addObject:marker];
//                    NSLog(@"Found Marker in cell vert:%d, hor:%d", j, p);
//                }
//            }
//            
//            if (tempArrayForCluster.count > 1) {
//                [_markersInBounds removeObjectsInArray:tempArrayForCluster];
//                GMSMarker *marker = [[GMSMarker alloc] init];
//                marker.position = [_mapView.projection coordinateForPoint:CGPointMake(gridCell.origin.x + (gridCell.size.width / 2), gridCell.origin.y + (gridCell.size.height / 2))];
//                [_clusters addObject:marker];
//            } else if (tempArrayForCluster.count == 1) {
//                GMSMarker *marker = [[GMSMarker alloc] init];
//                marker.position = ((GMSMarker *)tempArrayForCluster[0]).position;
//                [_clusters addObject:marker];
//            }
//            
//            [tempArrayForCluster removeAllObjects];
//        }
//        
//    }
    
    [self addFinalMarkers];
}

- (BOOL)checkDistance:(CGPoint)point1 point2:(CGPoint)point2 {
    float distance = sqrtf((point1.x - point2.x)*(point1.x - point2.x) + (point1.y - point2.y)*(point1.y - point2.y));
    if (distance < _gridSize) {
        return YES;
    } else {
        return NO;
    }
}

- (CGPoint)findMiddlePoint:(NSMutableArray *)clusterArray {
    float posX = 0;
    float posY = 0;
    for (int i = 0; i < clusterArray.count; i++) {
        posX += [_mapView.projection pointForCoordinate:(((GMSMarker *)clusterArray[i]).position)].x;
        posY += [_mapView.projection pointForCoordinate:(((GMSMarker *)clusterArray[i]).position)].y;
    }
    posX = posX / clusterArray.count;
    posY = posY / clusterArray.count;
    return CGPointMake(posX, posY);
}

@end
