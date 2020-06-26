//
//  NotesLocationViewController.swift
//  NoteAppFinalProject IOS
//
//  Created by user176491 on 6/25/20.
//  Copyright © 2020 Simranjeet kaur. All rights reserved.
//


import UIKit
import MapKit
import  CoreLocation
import CoreData

class NoteLocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var locationManager = CLLocationManager()
    var latitude:Double?
    var longitude:Double?
    let regionRadius:CLLocationDistance = 300
    let locationMAnager = CLLocationManager()
        

    
    
    @IBOutlet weak var myMapView: MKMapView!
    
   override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
           // myMapView.delegate = self
            

            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
    myMapView.showsUserLocation = true
    print("user latitude = \(latitude)")
     print("user longitude = \(longitude)")
     
          // let latitude: CLLocationDegrees = 43.64
           // let longitude: CLLocationDegrees = -79.38//
            

            
}
}
