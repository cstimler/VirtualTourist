//
//  TravelLocationsMapViewController.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var dataController:DataController!
    
    var locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        let tapAndPress = UILongPressGestureRecognizer(target: self, action: #selector(wasTappedAndPressed(_:)))
        tapAndPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(tapAndPress)
        // Do any additional setup after loading the view.
    }
 //   https://stackoverflow.com/questions/40894722/swift-mkmapview-drop-a-pin-annotation-to-current-location
    
    @objc func wasTappedAndPressed(_ recognizer:UIGestureRecognizer) {
        
        let point = recognizer.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        let newPin = MKPointAnnotation()
        newPin.coordinate = coordinate
        mapView.addAnnotation(newPin)
    }
    
}
