//
//  AppDelegate.swift
//  On The Map
//
//  Created by Ryan Berry on 11/24/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application( application, didFinishLaunchingWithOptions: launchOptions)
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!
        ]
        UINavigationBar.appearance().barTintColor  = UIColor(red: 0.001, green: 0.706, blue:0.903, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = attrs
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
       return self.orientationLock
        
    }
    
}



