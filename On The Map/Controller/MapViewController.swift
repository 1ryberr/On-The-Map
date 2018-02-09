//
//  MapViewController.swift
//  On The Map
//
//  Created by Ryan Berry on 11/25/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController{
    @IBOutlet weak var map: MKMapView!
    var sv : UIView!
    var studentList = [StudentInformation]()
    private  let UDACITY_URL = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100"
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        AppUtility.lockOrientation(.all)
        map.delegate = self
        studentList.removeAll()
        StudentInformationArray.info.getStudents(UDACITY_URL, sv: view)
        studentList = StudentInformationArray.info.studentList
        annotationFunc(list: studentList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
    }
    
     func annotationFunc(list:[StudentInformation]) {
        for item in list{
            let studentAnnotation = StudentCallOut(coordinate:CLLocationCoordinate2DMake(item.latitude!,item.longitude!), title:"  \(item.firstName ?? "First Name") \(item.lastName ?? "Last Name")", mediaURL: "\(item.mediaURL ?? "http://www.google.com")")
            self.map.addAnnotations([studentAnnotation])
        }
    }
    
    func removePinCoordinates() {
        let annotations = map.annotations
        map.removeAnnotations(annotations)
    }
    
    
    @IBAction func refreshMap(_ sender: Any) {
        removePinCoordinates()
        studentList.removeAll()
        StudentInformationArray.info.getStudents(UDACITY_URL, sv: view)
         studentList = StudentInformationArray.info.studentList
        annotationFunc(list: studentList)
        
        
        if studentList.isEmpty{
          StudentInformationArray.removeSpinner(spinner: sv)
            let alert = UIAlertController(title: "Invalid Link!", message: "This pin doesnt have a valid URL.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UdacityClient.sharedInstance.logOut{ (parsedResults, error) in
            print(parsedResults!)
        }
    }
    
    @IBAction func pinMyLocation(_ sender: Any) {
        
        let alert = UIAlertController(title: "Who are you?", message: "First and last name required.", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {action in })
        
        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            
            let firstName = (alert.textFields![0] as UITextField).text!
            let lastName = (alert.textFields![1] as UITextField).text!
            
            let controller: PinViewController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
            controller.firstName = firstName
            controller.lastName =  lastName
            self.present(controller, animated: true, completion: nil)
            
        })
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        alert.addTextField(configurationHandler: {textField in
            textField.backgroundColor = UIColor.white
            textField.placeholder = "First Name"
        })
        alert.addTextField(configurationHandler: {textfield in
            textfield.backgroundColor = UIColor.white
            textfield.placeholder = "Last Name"
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor) {
        
        let attrs = [NSAttributedStringKey.foregroundColor: color,
                     NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
    @objc func addBounceAnimationToView(view: UIView) {
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale") as CAKeyframeAnimation
        bounceAnimation.values = [ 2, 1, 2, 1]
        
        let timingFunctions = NSMutableArray(capacity: bounceAnimation.values!.count)
        
        for _ in  0...bounceAnimation.values!.count {
            timingFunctions.add(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        bounceAnimation.timingFunctions = timingFunctions as NSArray as? [CAMediaTimingFunction]
        bounceAnimation.isRemovedOnCompletion = false
        
        view.layer.add(bounceAnimation, forKey: "bounce")
        
    }
    
   func sendToWebView(_ customAnnotation: StudentCallOut) {
    
        
        if canOpenURL(string: customAnnotation.subtitle!){
    
            self.alertToLink(title: customAnnotation.title!, subtitle: customAnnotation.subtitle!)
        }else{
            
            let alert = UIAlertController(title: "Invalid Link!", message: "This pin doesnt have a valid URL.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func canOpenURL(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }

    
    func alertToLink(title: String, subtitle: String){
        
        let alert = UIAlertController(title: "\(title) has a URL.", message: "Would you like to view it.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            
            let controller: WebViewController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            controller.subtitle = subtitle
            self.navigationController?.pushViewController(controller, animated: true)
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in
            
        }
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func turnOffActivityAndAlert(){
        if studentList.isEmpty{
            StudentInformationArray.removeSpinner(spinner: sv)
            let alert = UIAlertController(title: "Invalid Link!", message: "This pin doesnt have a valid URL.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
        }
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier: String = "Pin"
        if annotation is StudentCallOut {
            var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let customView = Bundle.main.loadNibNamed("CustomCallOutView", owner: self, options: nil)![0] as! StudentCallOutView
        
        customView.layer.cornerRadius = 6
        customView.layer.borderWidth = 4
        customView.layer.borderColor = UIColor.white.cgColor
        
        var callOutViewFrame = customView.frame
        callOutViewFrame.origin = CGPoint(x: -callOutViewFrame.size.width/2 + 15, y: -callOutViewFrame.size.height)
        customView.frame = callOutViewFrame
        
        let customAnnotation = view.annotation as! StudentCallOut
        
        customView.subtitleLabel.text = customAnnotation.subtitle
        labelFunction(label: customView.titleLabel, text: customAnnotation.title!, color: .white)
        view.addSubview(customView)
    
        map.showAnnotations([customAnnotation], animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3){
            self.addBounceAnimationToView(view: customView)
        }
        if view.isSelected {
            sendToWebView(customAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKPinAnnotationView.self){
            
            let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60))
            mapView.setRegion(region, animated: true)
            
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
}

