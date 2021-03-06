//
//  LoginViewController.swift
//  On The Map
///Users/home/Desktop/On The Map/On The Map
//  Created by Ryan Berry on 11/25/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit
//import FBSDKLoginKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var acountLabel: UILabel!
    private  let UDACITY_URL = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100"
    var keyboardOnScreen = false
    var sv: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        keyBoardHideandShow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        AppUtility.lockOrientation(.portrait)
        authenticateUser()
        
//        if (FBSDKAccessToken.current() != nil) {
//            performSegue(withIdentifier:"mapsSegue", sender: nil)
//        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromAllNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    func getSessionID(userName: String, passWord: String){
        
        UdacityClient.sharedInstance.getSessionID(userName: userNameTextfield.text!, passWord: passwordTextfield.text!){(id, error) in
            
            guard (error == nil) else {
                
                if error?.localizedDescription == "Your request returned a status code other than 2xx!"{
                    performUIUpdatesOnMain({
                    self.acountLabel.text = "Check username and password"
                    })
                }else{
                    performUIUpdatesOnMain {
                     self.acountLabel.text = "Check internet connection"
                    }
                  LoginViewController.removeSpinner(spinner: self.sv)
                }
              LoginViewController.removeSpinner(spinner: self.sv)
                return
            }
            if !(id?.isEmpty)!{
                
                     DispatchQueue.main.async {
                        self.performSegue(withIdentifier:"mapsSegue", sender: nil)
                        
                }
              LoginViewController.removeSpinner(spinner: self.sv)
            }
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        
        guard let url = URL(string: "https://udacity.com") else {
            return 
        }
        if #available(iOS 12.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authentication to Udacity!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:{
                    if success {
                        self.performSegue(withIdentifier:"mapsSegue", sender: nil)
                        
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                })
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor){
        
        let attrs = [NSAttributedString.Key.foregroundColor: color,
                     NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        sv = LoginViewController.displaySpinner(onView: self.view)
        getSessionID(userName:  userNameTextfield.text!, passWord: passwordTextfield.text!)
        StudentInformationArray.info.userName = userNameTextfield.text
        userNameTextfield.text = ""
        passwordTextfield.text = ""
        
    }
    
//    @IBAction func fBButton(_ sender: Any) {
//        let readPermissions = ["public_profile"]
//        let loginManager = FBSDKLoginManager()
//        if let currentAccessToken = FBSDKAccessToken.current(), currentAccessToken.appID != FBSDKSettings.appID()
//        {
//            loginManager.logOut()
//        }
//
//        loginManager.logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
//            if ((error) != nil){
//                print("login failed with error: \(String(describing: error))")
//            } else if (result?.isCancelled)! {
//                print("login cancelled")
//            } else {
//                self.performSegue(withIdentifier:"mapsSegue", sender: nil)
//            }
//        }
//    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyBoardHideandShow(){
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIResponder.keyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIResponder.keyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y  -=  keyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen{
            view.frame.origin.y = 0
        }
        
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}

extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension LoginViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor(red: 0.001, green: 0.706, blue:0.903, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
