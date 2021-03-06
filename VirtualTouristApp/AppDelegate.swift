//
//  AppDelegate.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    // let's initialize our dataController in AppDelegate so it will be forwarded to the initial view controller to be seen upon startup (the TravelLocationsMapViewController):
  //  let dataController = DataController(modelName: "virtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
  //      dataController.load()
     /*
        let myVC = window?.rootViewController  as! TravelLocationsMapViewController
        myVC.dataController = dataController
     */
        
        // Based partly on: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack
   /*     if let rootVC = window?.rootViewController as? TravelLocationsMapViewController {
                    rootVC.dataController = dataController
                }   */
                return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //    saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      //  saveViewContext()
    }
    
    func saveViewContext() {
   //     try? dataController.viewContext.save()
    }


}

