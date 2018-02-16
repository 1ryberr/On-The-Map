//
//  PinViewController.swift
//  On The Map
//
//  Created by Ryan Berry on 11/28/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//
import MapKit
import UIKit

class PinViewController: UIViewController{
    
    @IBOutlet weak var whereTitle: UILabel!
    @IBOutlet weak var studyTitle: UILabel!
    @IBOutlet weak var todayTitle: UILabel!
    @IBOutlet weak var localTextField: UITextField!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    private  let UDACITY_URL = "https://parse.udacity.com/parse/classes/StudentLocation"
    private let UDACITY_STUDENT_URL = "https://www.udacity.com/api/users/\(StudentInformationArray.info.userName!)"
    var enterLocation = "Enter Your Location Here"
    var enterLink = "Enter a Link to Share Here"
    var coordinates = CLLocationCoordinate2D()
    var place: String = ""
    var objectId: String = ""
    var link : String = ""
    var name : (String, String)!
    var dict = [String: String]()
    var sv: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo()
        customizeView(view: submitButton, cornerRadius: 4, borderWidth: 2)
        customizeView(view: findButton, cornerRadius: 4, borderWidth: 2)
        customizeView(view: firstView, cornerRadius: 6, borderWidth: 7)
        customizeView(view: secondView, cornerRadius: 6, borderWidth: 7)
        
        AppUtility.lockOrientation(.portrait)
        textFieldFunction(textField: linkTextField, placeholder: enterLink)
        textFieldFunction(textField: localTextField, placeholder: enterLocation )
        firstViewIsHidden(false)
        
        checkIfFirstLaunch(key: "objectId")
        objectId = UserDefaults.standard.string(forKey: "objectId")!
        
        
        labelFunction(label: whereTitle, text: "Where Are You", color: UIColor.gray)
        labelFunction(label: studyTitle, text: "studying", color: UIColor.black)
        labelFunction(label: todayTitle, text: "today.", color:UIColor.gray)
        
        
    }
    
    
    
    
    func customizeView(view: UIView, cornerRadius: Int, borderWidth: Int){
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.layer.borderWidth = CGFloat(borderWidth)
        view.layer.borderColor = UIColor.white.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func getMapByAddress(_ locationMap: MKMapView?, address: String?){
        sv =  LoginViewController.displaySpinner(onView: self.view)
        firstViewIsHidden(true)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if let validPlacemark = placemarks?[0]{
                self.coordinates = (validPlacemark.location?.coordinate)!
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: (validPlacemark.location?.coordinate)!, span: span)
                locationMap?.setRegion(region, animated: true)
                
                let myInfo = StudentCallOut(coordinate:CLLocationCoordinate2DMake(self.coordinates.latitude,self.coordinates.longitude), title:" \(self.dict["firstName"]!) \(self.dict["lastName"]!)", mediaURL: "The url you enter goes here!")
                locationMap?.addAnnotation(myInfo)
                self.dict["latitude"] = "\(self.coordinates.latitude)"
                self.dict["longitude"] = "\(self.coordinates.longitude)"
                LoginViewController.removeSpinner(spinner: self.sv)
                
            } else {
                
                let alert = UIAlertController(title: "Error", message: "Geolocation has failed! Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                    LoginViewController.removeSpinner(spinner: self.sv)
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
    }
    
    func flip() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: firstView, duration: 1.0, options: transitionOptions, animations: {
            
        })
        
        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
            
        })
    }
    
    func checkIfFirstLaunch(key: String){
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            
        } else {
            
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set( "", forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor){
        
        let attrs = [NSAttributedStringKey.foregroundColor: color,
                     NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
    func textFieldFunction(textField: UITextField, placeholder: String){
        
        textField.delegate = self
        textField.text = placeholder
        let pinTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.white,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "Georgia-Bold", size: 24)!,
            NSAttributedStringKey.strokeWidth.rawValue: -0.05]
        textField.defaultTextAttributes = pinTextAttributes
        textField.textAlignment = .center
    }
    
    func firstViewIsHidden(_ enabled: Bool) {
        
        whereTitle.isHidden = enabled
        studyTitle.isHidden = enabled
        todayTitle.isHidden = enabled
        localTextField.isHidden = enabled
        firstView.isHidden = enabled
        findButton.isHidden = enabled
        
        if enabled{
            map.isHidden = false
            linkTextField.isHidden = false
            secondView.isHidden = false
            submitButton.isHidden = false
            
        }else{
            map.isHidden = true
            linkTextField.isHidden = true
            secondView.isHidden = true
            submitButton.isHidden = true
        }
        
    }
    
    func alertDialog(title: String, message: String, buttonTitle: String){
        let controller = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        self.present(controller, animated: true)
    }
    
    func userInfo(){
        
        UdacityClient.sharedInstance.getPublicUserData(url: UDACITY_STUDENT_URL){name, error in
            guard (error == nil) else {
                performUIUpdatesOnMain({
                    self.alertDialog(title: "Error", message: "Name was not retrieved! Try again later.", buttonTitle: "OK")
                })
                return
            }
            let name = name
            
            self.dict = ["firstName": name.0,"lastName": name.1]
            
        }
        
    }
    
    func updateStudentLocation(url: String, objectID: String, dict: [String:String]){
        sv = LoginViewController.displaySpinner(onView: self.view)
        let newUrl = url + "/" + objectId
        UdacityClient.sharedInstance.updateStudentLocation(url: newUrl, jsonBodyString: UdacityClient.sharedInstance.jsonBodyString(dict: dict)){(data, error) in
            guard (error == nil) else {
                performUIUpdatesOnMain({
                    LoginViewController.removeSpinner(spinner: self.sv)
                    self.alertDialog(title: "Error", message: "Network Error! Try again later.", buttonTitle: "OK")
                })
                return
            }
            LoginViewController.removeSpinner(spinner: self.sv)
            if let datum = data{
                print(datum)
            }else {
                performUIUpdatesOnMain {
                    self.alertDialog(title: "Error", message: "Network Error! Try again later.", buttonTitle: "OK")
                }
                
            }
        }
        
    }
    
    func postStudentLocation(url:String, dict: [String:String]){
        sv = LoginViewController.displaySpinner(onView: self.view)
        UdacityClient.sharedInstance.postStudentLocation(url: url, jsonBodyString: UdacityClient.sharedInstance.jsonBodyString(dict: dict)){ (objectId, error) in
            guard (error == nil) else {
                performUIUpdatesOnMain({
                    self.alertDialog(title: "Error", message: "Network Error! Try again later.", buttonTitle: "OK")
                    LoginViewController.removeSpinner(spinner: self.sv)
                    
                })
                return
            }
            if let objectId = objectId{
                self.objectId = objectId
                UserDefaults.standard.set(objectId, forKey: "objectId")
                LoginViewController.removeSpinner(spinner: self.sv)
        
            }
        }
    }
    
    func addBounceAnimationToView(view: UIView){
        
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
    
    
    @IBAction func findOnTheMap(_ sender: Any) {
        
        firstViewIsHidden(true)
        place = localTextField.text!
        dict["mapString"] = place
        localTextField.resignFirstResponder()
        getMapByAddress(map,address: place)
        flip()
        
    }
    
    @IBAction func cancelPinDrop(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func submitPin(_ sender: Any) {
        link = linkTextField.text!
        dict["link"] = link
        if objectId.isEmpty {
            dismiss(animated: true, completion: {
                
                self.postStudentLocation(url: self.UDACITY_URL, dict: self.dict)
            })
            
        }else{
            let alert = UIAlertController(title: "Update", message: "This will update your location and information.", preferredStyle: UIAlertControllerStyle.alert)
            
            let actionOK = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: {action in
                
                self.updateStudentLocation(url: self.UDACITY_URL, objectID:  self.objectId, dict: self.dict)
                self.dismiss(animated: true, completion: {})
            })
            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {action in
                self.dismiss(animated: true, completion: {})
                
            })
            
            alert.addAction(actionOK)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
}

extension PinViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}

extension PinViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if  annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.annotation = annotation
            
        } else {
            annotationView?.annotation = annotation
        }
        
        return  annotationView
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
        customView.subtitleLabel.text = " \(localTextField.text!)"
        
        labelFunction(label: customView.titleLabel, text:"\(customAnnotation.title!)", color: .white)
        view.addSubview(customView)
        
        addBounceAnimationToView(view: customView)
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKPinAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
}

