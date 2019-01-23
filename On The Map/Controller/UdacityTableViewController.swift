//
//  UdacityTableViewController.swift
//  On The Map
//
//  Created by Ryan Berry on 11/25/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit

class UdacityTableViewController: UITableViewController  {
    @IBOutlet var studentTableView: UITableView!
    let UDACITY_URL = "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt"
    let refreshControls = UIRefreshControl()
    var sv : UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTableView.backgroundView = UIImageView(image: UIImage(named: "logo-u"))
        studentTableView.reloadData()
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    func loadStudentData(){
        
        UdacityClient.sharedInstance.getStudentInfo(url: UDACITY_URL){ (students, error) in
            guard (error == nil) else {
                print("\(error!)")
                LoginViewController.removeSpinner(spinner: self.sv)
                performUIUpdatesOnMain {
                    
                    let alert = UIAlertController(title: "Network Error", message: "Check Network Connection!", preferredStyle: UIAlertController.Style.actionSheet)
                    
                    let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                    })
                    alert.addAction(actionOK)
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            if let students = students {
                var myClass = [StudentInformation]()
                myClass = students
                myClass = myClass.filter { $0.latitude != nil || $0.longitude != nil}
                DispatchQueue.main.async {
                    StudentInformationArray.info.studentList = myClass
                    self.studentTableView.reloadData()
                    
                }
                
                
            }
        }
        
    }
    
    func alertToLink(title: String, subtitle: String){
        let alert = UIAlertController(title: "\(title) has a link.", message: "Would you like to view it.", preferredStyle: UIAlertController.Style.alert)
        
        let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
            
            let controller: WebViewController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            controller.subtitle = subtitle
            self.navigationController?.pushViewController(controller, animated: true)
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
            
        }
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func canOpenURL(string: String?) -> Bool {
        
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func refresh(){
        
        refreshControls.addTarget(nil, action: #selector(didRefresh), for: .valueChanged)
        refreshControls.tintColor = UIColor.gray
        studentTableView.refreshControl = refreshControls
    }
    
    @objc func didRefresh(event: UIControl.Event) {
        
        StudentInformationArray.info.studentList.removeAll()
        loadStudentData()
        studentTableView.reloadData()
        refreshControls.endRefreshing()
        
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor){
        
        let attrs = [NSAttributedString.Key.foregroundColor: color,
                     NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
    func sendToWebView(_ studentInfo: StudentInformation) {
        
        if canOpenURL(string: studentInfo.mediaURL!){
            
            self.alertToLink(title: "\(studentInfo.firstName!) \(studentInfo.lastName!)", subtitle:"\(studentInfo.mediaURL!)")
            
        }else{
            
            let alert = UIAlertController(title: "Invalid Link!", message: "This pin doesnt have a valid URL.", preferredStyle: UIAlertController.Style.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
            })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationArray.info.studentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StudentTableViewCell
        let people = StudentInformationArray.info.studentList[indexPath.row]
        labelFunction(label: cell.nameLabel, text: "\(people.firstName ?? "First Name" ) \(people.lastName ?? "Last Name" )", color: UIColor(red: 0.001, green: 0.706, blue:0.903, alpha: 1))
        cell.linkLabel?.text = "\(people.mediaURL ?? "http://www.google.com")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentTableView.reloadData()
        studentTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let people = StudentInformationArray.info.studentList[indexPath.row]
        sendToWebView(people)
        
    }
    
    @IBAction func pinMyLocation(_ sender: Any) {
        
        if StudentInformationArray.info.userName == nil{
            let alert = UIAlertController(title: "Udacity Login Needed for This Option", message: "Please log out and Login again with the Udacity Login!", preferredStyle: UIAlertController.Style.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
            })
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }else{
            let controller: PinViewController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UdacityClient.sharedInstance.logOut{ (parsedResults, error) in
            print(parsedResults!)
        }
    }
}



