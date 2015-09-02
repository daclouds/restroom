//
//  ViewController.swift
//  restroom
//
//  Created by daclouds on 2015. 9. 1..
//  Copyright (c) 2015년 codeport. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import Parse

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var span: MKCoordinateSpan
    var midCoorinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    let manager = CLLocationManager()
    
    let latitudeDelta = 0.01
    let longitudeDelta = 0.01

    required init(coder aDecoder: NSCoder) {
        
        let midPoint = CGPointFromString("{37.60,126.91}")
        midCoorinate = CLLocationCoordinate2DMake(CLLocationDegrees(midPoint.x), CLLocationDegrees(midPoint.y))
        self.annotations = []
        span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        manager.delegate = self
        
//        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        
        manager.startUpdatingLocation()
        
        mapView.region = MKCoordinateRegionMake(midCoorinate, span)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    MARK: MKMapViewDelegate
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        println("mapViewDidFinishRenderingMap")
        
        var query = PFQuery(className:"restroom")
        println(mapView.centerCoordinate.latitude.description, mapView.centerCoordinate.longitude.description)
        
//        midCoorinate.latitude = mapView.centerCoordinate.latitude
//        midCoorinate.longitude = mapView.centerCoordinate.longitude
        
        query.whereKey("latitude", greaterThan: mapView.centerCoordinate.latitude - latitudeDelta).whereKey("latitude", lessThan: mapView.centerCoordinate.latitude + latitudeDelta)
        query.whereKey("longitude", greaterThan: mapView.centerCoordinate.longitude - longitudeDelta).whereKey("longitude", lessThan: mapView.centerCoordinate.longitude + longitudeDelta)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.mapView.removeAnnotations(self.annotations)
                    for object in objects {
                        var anotation = MKPointAnnotation()
                        anotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(object.valueForKey("latitude") as! Float), CLLocationDegrees(object.valueForKey("longitude") as! Float))
                        anotation.title = object.valueForKey("name") as! String
                        anotation.subtitle = (object.valueForKey("address1") as! String)
                        self.annotations.append(anotation)
                        println((object.valueForKey("name") as! String).utf8, (object.valueForKey("address1") as! String).utf8, object.valueForKey("latitude"), object.valueForKey("longitude"))
                    }
                    self.mapView.addAnnotations(self.annotations)
                }
            } else {
                println(error)
            }
        }
//        mapView.region = MKCoordinateRegionMake(midCoorinate, span)
    }
    
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        println("mapViewDidFinishLoadingMap")
    }
    
//    MARK: CLLocationManagerDelegate
    func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.setCenterCoordinate(userLocation.location.coordinate, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locationManager didUpdateLocations")
    }
    
}

