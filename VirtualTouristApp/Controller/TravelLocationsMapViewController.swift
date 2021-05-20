//
//  TravelLocationsMapViewController.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController:DataController!
    
    var locationManager = CLLocationManager()
    
    var pin: Pin!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
   // var myCLLocation: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    func setUpFetchedResultsController(_ latitude: inout Double, _ longitude: inout Double) {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        latitude = roundToFourDecimalPlaces(latitude)
        longitude = roundToFourDecimalPlaces(longitude)
        let lat1 = String(format: "%.4f", latitude)
        let lon1 = String(format: "%.4f", longitude)
        let predicate = NSPredicate(format: "latitude == \(lat1) AND longitude == \(lon1)")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
    //    let result = try? dataController.viewContext.fetch(fetchRequest)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count == 0 {
                let pin = Pin(context: dataController.viewContext)
                // need to round off to 4 places to match accuracy of fetch request:
                // https://stackoverflow.com/questions/34929932/round-up-double-to-2-decimal-places
                pin.latitude = roundToFourDecimalPlaces(latitude)
                pin.longitude = roundToFourDecimalPlaces(longitude)
            //    print(pin)
                do {
                    try dataController.viewContext.save()
            //        dataController.viewContext.processPendingChanges()
                }
                catch {
                    print("There is an error")
                    print(error)}
            } else {
                let pin = Pin(context: dataController.viewContext)
                pin.latitude = latitude
                pin.longitude = longitude
                print(pin)
                do {
                    try dataController.viewContext.save() }
                catch {print(error)}
            }
        } catch {
            print("Unable to fetch: \(error.localizedDescription)")
        }
    }
    
    // https://stackoverflow.com/questions/34929932/round-up-double-to-2-decimal-places
    func roundToFourDecimalPlaces(_ number: Double) -> Double {
        return (number*10000).rounded()/10000
    }

    func getStartingRegionForMap() {
        // if this is the first launch the following code will do nothing and the map will open with its default location:
        if let startingLatitude = UserDefaults.standard.value(forKey: "latitude") {
            if let startingLongitude = UserDefaults.standard.value(forKey: "longitude") {
                if let startingLatitudeDelta = UserDefaults.standard.value(forKey: "latitudeDelta") {
                    if let startingLongitudeDelta = UserDefaults.standard.value(forKey: "longitudeDelta") {
                    
                    let center = CLLocationCoordinate2D(latitude: startingLatitude as! Double, longitude: startingLongitude as! Double)
                    let span = MKCoordinateSpan(latitudeDelta: startingLatitudeDelta as! Double, longitudeDelta: startingLongitudeDelta as! Double)
                    let region = MKCoordinateRegion(center: center, span: span)
                        mapView.setRegion(region, animated: false)
                    }
                }
            }
        }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        let tapAndPress = UILongPressGestureRecognizer(target: self, action: #selector(wasTappedAndPressed(_:)))
        tapAndPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(tapAndPress)
        getStartingRegionForMap()
        
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        storeEndMapLocationAndZoom()
    }
    
    func storeEndMapLocationAndZoom() {
        let a = mapView.centerCoordinate.latitude as Double
        UserDefaults.standard.setValue(a, forKey: "latitude")
        let b = mapView.centerCoordinate.longitude as Double
        UserDefaults.standard.setValue(b, forKey: "longitude")
        let c = mapView.region.span.latitudeDelta as Double
        UserDefaults.standard.setValue(c, forKey: "latitudeDelta")
        let d = mapView.region.span.longitudeDelta as Double
        UserDefaults.standard.setValue(d, forKey: "longitudeDelta")
        
    }
 //   https://stackoverflow.com/questions/40894722/swift-mkmapview-drop-a-pin-annotation-to-current-location
    
    @objc func wasTappedAndPressed(_ recognizer:UIGestureRecognizer) {
        
        let point = recognizer.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        let newPin = MKPointAnnotation()
        newPin.coordinate = coordinate
        mapView.addAnnotation(newPin)
    }
    
    //obtains latitude and longitude after pin tap in order to compare with "Pin" data
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Did select annotation view.")
        var latitude = view.annotation!.coordinate.latitude
        var longitude = view.annotation!.coordinate.longitude
        setUpFetchedResultsController(&latitude, &longitude)
        
    }
    
    // provides a "pin" view/appearance for the map point annotation:
    func mapView(_ mapView:MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
         {
            pinView.annotation = annotation
            return pinView
        }
        else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            // I like green
            pinView.pinTintColor = .green
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            return pinView
        }
        
        
    }
}
