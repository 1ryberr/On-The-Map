//
//  StudentInformationArray.swift
//  On The Map
//
//  Created by Ryan Berry on 12/31/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit
final class StudentInformationArray: NSObject{
    static let info = StudentInformationArray()
    private override init() {}
    var userName : String!
    var studentList = [Results]()
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}



















