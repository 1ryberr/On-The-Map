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
    
     var studentList :[StudentInformation]!
    
    func getStudents(_ url: String, sv: UIView) {
       
        var spinnerView: UIView
        spinnerView = StudentInformationArray.displaySpinner(onView: sv)
        
        var myClass : [StudentInformation]!
        UdacityClient.sharedInstance.getStudentInfo(url: url){ (students, error) in
            guard (error == nil) else {
                print("\(error!)")
                return
            }
            if let students = students {
                myClass = students
                self.studentList = myClass.filter { $0.latitude != nil || $0.longitude != nil}
               
              StudentInformationArray.removeSpinner(spinner: spinnerView)
            }
        }
    }
}

    extension StudentInformationArray {
        
        class func displaySpinner(onView : UIView) -> UIView {
            let spinnerView = UIView.init(frame: onView.bounds)
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            
            let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            ai.startAnimating()
            ai.center = spinnerView.center
            performUIUpdatesOnMain {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            }
            
            return spinnerView
        }
        
        class func removeSpinner(spinner :UIView) {
            
            performUIUpdatesOnMain {
                spinner.removeFromSuperview()
                
            }
        }
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


















    

