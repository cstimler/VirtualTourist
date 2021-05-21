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
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var dataController:DataController!
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadView()
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
    
    func addPhotosToNewPin(isNewPin: Bool) {
        if !isNewPin {
            self.setupFetchedResultsController()
        }
        else {
            VTClient.requestPhotosList(lat: pin.latitude, lon: pin.longitude, page: 1, perPage: 15) { (success, error) in
                if success {
                    VTClient.downloadPhotos(dataController: self.dataController, pin: self.pin) { (success, error) in
                        if success {
                            self.setupFetchedResultsController()
                        }
                    }
                }
            }
        }
    }
    
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return the number of sections
        return fetchedResultsController.sections?.count ?? 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of items
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        let myFile = aPhoto.file
        if let myFile = myFile {
        cell.photoCell.image = UIImage(data: myFile)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

}
