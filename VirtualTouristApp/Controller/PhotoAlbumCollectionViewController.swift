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
    
    var dataController:DataController!
    
    var numOfPhotos: Int = 15
    
    var pages = 1
    
    
    @IBAction func initiateNewCollection(_ sender: Any) {
        var arrayOfFetches: [Photo]
        var objectIDs = [NSManagedObjectID]()
        var indexPaths = [IndexPath]()
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
        for photo in arrayOfFetches {
            print(photo)
            objectIDs.append(photo.objectID)
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error.localizedDescription)")
        }
        print("11111")
        var test1: [Photo]
        test1 = fetchedResultsController?.fetchedObjects ?? []
        print("22222")
        for photo in test1 {
            indexPaths.append((fetchedResultsController?.indexPath(forObject: photo)!)!)
            print("33333")
        }
        
        for photo in arrayOfFetches {
            print("44444")
            print(photo)
            indexPaths.append((fetchedResultsController?.indexPath(forObject: photo)!)!)
        }
        for obj in objectIDs {
            print("55555")
            print(indexPaths.count)
            print(objectIDs.count)
            deletePhoto(at: IndexPath(item: 0, section: 0))
        }
        self.loadView()
        isNewPin = true
        addPhotosToNewPin(isNewPin: isNewPin)
    }
    
    
    func clearAndReloadPins(_ sender: Any) {
        // https://www.generacodice.com/en/articolo/177795/DeleteReset-all-entries-in-Core-Data:
        // useful for resetting program in preparation for submission: erases all Pins from plist as well as Photo (because Pin is a one-to-many "cascading" relationship)
        
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
        print("ENTERED FETCHED resULSTs Controller!!!!")
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
        // setupFetchedResultsController()
        addPhotosToNewPin(isNewPin: isNewPin)
        print("before self loadview")
        self.loadView()
        print("after self loadview")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? dataController.viewContext.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pin)
        
        if UIDevice.current.orientation.isLandscape {
                let space:CGFloat = 3.0
            let dimension = (view.frame.size.width - (5*space))/6.0
                flowLayout.minimumInteritemSpacing = space
                flowLayout.minimumLineSpacing = space
                    flowLayout.itemSize = CGSize(width:dimension, height:dimension)
            
        } else {      // unfortunately this includes upside down
             
                
                let space:CGFloat = 3.0
            let dimension = (view.frame.size.width - (2*space))/3.0
                flowLayout.minimumInteritemSpacing = space
                flowLayout.minimumLineSpacing = space
                    flowLayout.itemSize = CGSize(width:dimension, height:dimension)
            
        }
        
        // callNotificationsAdd() here or in other event??

     
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func callNotificationAdd() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotated(_notification: Notification) {
               if UIDevice.current.orientation.isLandscape {
                       let space:CGFloat = 3.0
                let dimension = (view.frame.size.width - (5*space))/6.0
                       flowLayout.minimumInteritemSpacing = space
                       flowLayout.minimumLineSpacing = space
                           flowLayout.itemSize = CGSize(width:dimension, height:dimension)
                   
               } else {
                    
                       
                       let space:CGFloat = 3.0
                let dimension = (view.frame.size.width - (2*space))/3.0
                       flowLayout.minimumInteritemSpacing = space
                       flowLayout.minimumLineSpacing = space
                           flowLayout.itemSize = CGSize(width:dimension, height:dimension)
                   
               }
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // taken from: https://learnappmaking.com/random-numbers-swift/
    func random(_ n:Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    func addPhotosToNewPin(isNewPin: Bool) {
        print("Gets to addPhotosToNewPin")
        if !isNewPin {
            print("1b")
            self.setupFetchedResultsController()
        }
        else {
            print("Gets to else clause")
            var randNum: Int = 1
            if pages > 2 {
                let limit = pages - 1
              randNum = random(limit) + 1
            }
            VTClient.requestPhotosList(lat: pin.latitude, lon: pin.longitude, page: randNum, perPage: 15) { (success, error, pages, numPhotos) in
                if success {
                    print("2b")
                    // saves the number of pages (of 15 photos each) that exists in the Flickr repository
                    self.pages = pages
                    if numPhotos < 15 {
                        // we should decrease the number of placeholders if there are less than 15 total photos available:
                    self.numOfPhotos = numPhotos
                    } else {
                        // resets to default of 15 if we had deleted some photos from the
                        self.numOfPhotos = 15
                    }
                    if numPhotos == 0 {
                        self.showMapFailure(message: "Sorry but there are no photos available to show at this location!")
                    }
                    VTClient.downloadPhotos(dataController: self.dataController, pin: self.pin) { (success, error) in
                        if success {
                            print("reached completion in the addtophotos")
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
        //return the number of sections
     //   return fetchedResultsController?.sections?.count ?? 1
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of items
     //   new pins should show the placeholders, old pins should not!
        if isNewPin {
            return numOfPhotos
        } else {
            return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        }
    }
// https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift/51746517#51746517
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  /*      let aPhoto = fetchedResultsController?.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        cell.photoCell.image = UIImage(named: "VirtualTourist_180")
        let myFile = aPhoto?.file
        if let myFile = myFile {
        cell.photoCell.image = UIImage(data: myFile)
          }
        return cell   */
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.photoCell.image = UIImage(named: "VirtualTourist_180")
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
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */


