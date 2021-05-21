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
    // this is the "pin" which will be passed to the next view controller (PhotoAlbumCollectionView):
    var pin: Pin!
    
    var isNewPin: Bool = false
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
   // var myCLLocation: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    // load pins that had been placed in a previous session:
    func loadOldPins() {
        var pins:[Pin]
        var annotations = [MKPointAnnotation]()
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptork = NSSortDescriptor(key: "creationDate", ascending: true)
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
        } catch {
            // There are no old pins?
            print(error)
            return
        }
        if pins.count == 0 {return}
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
        
    }
    
    func setUpFetchedResultsController(_ latitude: inout Double, _ longitude: inout Double) {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        // must be sure that the floats are formatted in a reproducible manner:
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
                // this is a new pin so lets create it, put it on the map, and save it globally
                let pin = Pin(context: dataController.viewContext)
                // need to round off to 4 places to match accuracy of fetch request:
                // https://stackoverflow.com/questions/34929932/round-up-double-to-2-decimal-places
                // rounding may be redundant as this has already been done above:
                pin.latitude = roundToFourDecimalPlaces(latitude)
                pin.longitude = roundToFourDecimalPlaces(longitude)
                print(pin) // debugging
                do {
                    // update the context:
                    try dataController.viewContext.save()
                    // save the local pin as class variable to be passed to next vc
                    self.pin = pin
            //        dataController.viewContext.processPendingChanges()
                    isNewPin = true
                }
                catch {
                    print("There is an error")
                    print(error)}
            } else {
                // pin is an "old" pin since it was obtained by the fetch above; let's just pass it into the global variable to be sent to the next vc
                pin = fetchedResultsController.fetchedObjects?[0]
    }
        } catch {
            print(error)
        }
        
        // either way we must segue to the next vc:
        performSegue(withIdentifier: "fromMapToPhotos", sender: self)
    }
    
    
    // Obtained at: https://stackoverflow.com/questions/39620217/nsfetchedresultscontroller-couldnt-read-cache-file-to-update-store-info-time
    // NSFetchedResultsController change tracking methods
        func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
            // empty: see documentation
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
        loadOldPins()
        
        
        
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
    
    //Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotoAlbumCollectionViewController
        
        controller.dataController = self.dataController
        controller.pin = self.pin
        controller.isNewPin = self.isNewPin
    }
}
