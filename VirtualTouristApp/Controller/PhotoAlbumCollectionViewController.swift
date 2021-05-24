//
//  PhotoAlbumCollectionViewController.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import UIKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotoAlbumCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var pin: Pin!
    
    var isNewPin: Bool!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>?
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var dataController:DataController!
    
    var numOfPhotos: Int = 15
    
    var pages = 1
    
    var fetchNumber: Int = 0
    
    
    @IBAction func initiateNewCollection(_ sender: Any) {
        var arrayOfFetches: [Photo]
        var objectIDs = [NSManagedObjectID]()
      //  var indexPaths = [IndexPath]()
        
        // disable Collection Button and reset fetchNumber at the start of a refresh of photos (when fetch number reaches numOfPhotos we can re-enable the "New Collection" button):
        newCollectionButton.isEnabled = false
        fetchNumber = 0
        // fetch all current photos in display:
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            arrayOfFetches = try dataController.viewContext.fetch(fetchRequest)
        } catch {
            fatalError("Unable to fetch: \(error.localizedDescription)")
        }
        // get a list of object ids in order to know exactly how many photos there are:
        for photo in arrayOfFetches {
            print(photo)
            objectIDs.append(photo.objectID)
        }
        // in order to delete properly from the viewController, we will need to repeat the fetch with a fetchedResultsController:
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error.localizedDescription)")
        }
       /*
        var test1: [Photo]
        test1 = fetchedResultsController?.fetchedObjects ?? []
        
        for photo in test1 {
            indexPaths.append((fetchedResultsController?.indexPath(forObject: photo)!)!)
            
        }
        
        for photo in arrayOfFetches {
            
           // print(photo) - debugging point
            indexPaths.append((fetchedResultsController?.indexPath(forObject: photo)!)!)
        }   */
        // we don't use the "obj" below, but we use the number of objects so that we repeat the for-if the correct number of times:
        for obj in objectIDs {
            // below was from some trial and error, but it makes sense that as objects are deleted the list is pared from right to left with empty places filled in by objects from the right, so the object at the very start position is the last to go:
            deletePhoto(at: IndexPath(item: 0, section: 0))
        }
        self.loadView()
        isNewPin = true
        addPhotosToNewPin(isNewPin: isNewPin)
    }
    
    // I don't use this function in the app, but it can be very useful to reset the entire persistent memory, so I leave it here for future reference:
    func clearAndReloadPins(_ sender: Any) {
        // https://www.generacodice.com/en/articolo/177795/DeleteReset-all-entries-in-Core-Data:
        // useful for resetting program: erases all Pins from plist as well as Photo (because Pin is a one-to-many "cascading" relationship)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(deleteRequest)
        }
        catch {
            print(error)
        }
    }
    
    
    func setupFetchedResultsController() {

        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, //cacheName: "\(pin)") caused crashes
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
            // good place to turn back on enabling of "New Collection" button when the final "setupFetchedResultsController" has completed running:
            countNumberOfFetches()
        } catch {
            fatalError("Unable to fetch: \(error.localizedDescription)")
        }
    }
    // Obtained at: https://stackoverflow.com/questions/39620217/nsfetchedresultscontroller-couldnt-read-cache-file-to-update-store-info-time
    // NSFetchedResultsController change tracking methods
        func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
            // empty: see documentation
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Disable "New Collections" button here while the photos are being added:
        newCollectionButton.isEnabled = false
        addPhotosToNewPin(isNewPin: isNewPin)
        self.loadView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? dataController.viewContext.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(pin)
        mathForCalculatingCollectionViewCell()
        // this notification might be redundant now that the viewController spacing is handled by the extension at the very bottom of the page
        callNotificationAdd()
     
    }

    func countNumberOfFetches() {
        fetchNumber = fetchNumber + 1
        if fetchNumber == numOfPhotos {
            newCollectionButton.isEnabled = true
        }
    }
    
    func callNotificationAdd() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotated(_notification: Notification) {
               mathForCalculatingCollectionViewCell()
    }
    
    // boilerplate for fitting images nicely into collection view (take from earlier Udacity provided code):
    func mathForCalculatingCollectionViewCell() -> CGFloat {
        var dimension: CGFloat
        
        if UIDevice.current.orientation.isLandscape {
                let space:CGFloat = 3.0
         dimension = (view.frame.size.width - (5*space))/6.0
                flowLayout.minimumInteritemSpacing = space
                flowLayout.minimumLineSpacing = space
                    flowLayout.itemSize = CGSize(width:dimension, height:dimension)
            
        } else {
             
                
                let space:CGFloat = 3.0
         dimension = (view.frame.size.width - (2*space))/3.0
                flowLayout.minimumInteritemSpacing = space
                flowLayout.minimumLineSpacing = space
                    flowLayout.itemSize = CGSize(width:dimension, height:dimension)
            
            
        }
        return dimension
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // taken from: https://learnappmaking.com/random-numbers-swift/
    func random(_ n:Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    func addPhotosToNewPin(isNewPin: Bool) {
        if !isNewPin {
            self.setupFetchedResultsController()
            // Re-enable "New Controller" button here for "old pins":
            newCollectionButton.isEnabled = true
        }
        else {
            var randNum: Int = 1
            if pages > 2 {
                let limit = pages - 1
              randNum = random(limit) + 1
            }
            VTClient.requestPhotosList(lat: pin.latitude, lon: pin.longitude, page: randNum, perPage: 15) { (success, error, pages, numPhotos) in
                if success {
                    // saves the number of pages (of 15 photos each) that exists in the Flickr repository
                    self.pages = pages
                    if numPhotos < 15 {
                        // we should decrease the number of placeholders if there are less than 15 total photos available:
                    self.numOfPhotos = numPhotos
                    } else {
                        // resets to default of 15 if we had deleted some photos from the old set (in case we are refreshing using the "New Collection" button) using decrementNumberOfPhotosInCollectionView:
                        self.numOfPhotos = 15
                    }
                    // provide a message if there are no photos to display:
                    if numPhotos == 0 {
                        self.showMapFailure(message: "Sorry but there are no photos available to show at this location!")
                    }
                    VTClient.downloadPhotos(dataController: self.dataController, pin: self.pin) { (success, error) in
                        if success {
                           
                            self.setupFetchedResultsController()
                            self.loadView()
                        } else {
                            print("reached error in photos")
                        }
                    }
                } else {
                    print("reached error in photo list")
                    print(error)}
            }
        }
    }
    
    // lower the number of items in the collection view (via "numberOfItemsInSection") in order to prevent a default "placeholder" from appearing after a photo is deleted:
    func decrementNumberOfPhotosInCollectionView() {
        var localPhotoNum = numOfPhotos
        localPhotoNum = localPhotoNum - 1
        numOfPhotos = localPhotoNum
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController?.object(at: indexPath)
        if let photoToDelete = photoToDelete {
            dataController.viewContext.delete(photoToDelete) }
        try? dataController.viewContext.save()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
     //   return fetchedResultsController?.sections?.count ?? 1
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of items
     //   new pins should show the placeholders, old pins should not!
        if isNewPin {
            // only make enough placeholders for the number of available photos; e.g., if there are only 8 photos available at a site, only create 8 placeholders.
            return numOfPhotos
        } else {
            // old pins should return their stored number of photos:
            return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        }
    }
// https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift/51746517#51746517
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        // here is the placeholder image:
        cell.photoCell.image = UIImage(named: "VirtualTourist_180")
        // the inequality below is necessary because the total number of images is set above in "numberOfItemsInSection" which may be greater than the number of available images at any given moment while the collection view is being populated with photos.  Without this inequality, the "cellForItemAt" woud attempt to access at "(at: indexPath)" that does not yet exist with a resultant error!
        if indexPath.item < fetchedResultsController?.sections?[0].numberOfObjects ?? 0 {
            let aPhoto = fetchedResultsController?.object(at: indexPath)
            let myFile = aPhoto?.file
            if let myFile = myFile {
            cell.photoCell.image = UIImage(data: myFile)
              }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
        // this avoids the appearance of placeholders as photos are deleted from the collection view:
        decrementNumberOfPhotosInCollectionView()   
        self.loadView()
    }

    func showMapFailure(message: String) {
        DispatchQueue.main.async {
        let alertVC = UIAlertController(title: "NO PHOTOS!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertVC, animated: true, completion: nil)
    }
    }
}
// adapted from: https://stackoverflow.com/questions/38028013/how-to-set-uicollectionviewcell-width-and-height-programmatically
    extension PhotoAlbumCollectionViewController: UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
                let dimension = mathForCalculatingCollectionViewCell()
                return CGSize(width: dimension, height: dimension)
        }

    
    }
