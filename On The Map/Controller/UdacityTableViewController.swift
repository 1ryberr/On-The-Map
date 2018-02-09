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
    var studentList: [StudentInformation]!
    var sv : UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentTableView.backgroundView = UIImageView(image: UIImage(named: "logo-u"))
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        StudentInformationArray.info.getStudents(UDACITY_URL, sv: view)
        studentList = StudentInformationArray.info.studentList
        studentTableView.reloadData()
    }
    
    func alertToLink(title: String, subtitle: String){
        let alert = UIAlertController(title: "\(title) has a link.", message: "Would you like to view it.", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    @objc func didRefresh(event: UIControlEvents) {
        studentList.removeAll()
        StudentInformationArray.info.getStudents(UDACITY_URL, sv: view)
        studentList = StudentInformationArray.info.studentList
        studentTableView.reloadData()
        refreshControls.endRefreshing()
        
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor){
        
        let attrs = [NSAttributedStringKey.foregroundColor: color,
                     NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ]
        
         let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
     func sendToWebView(_ studentInfo: StudentInformation) {

        if canOpenURL(string: studentInfo.mediaURL!){
            
            self.alertToLink(title: "\(studentInfo.firstName!) \(studentInfo.lastName!)", subtitle:"\(studentInfo.mediaURL!)")
            
        }else{
            
            let alert = UIAlertController(title: "Invalid Link!", message: "This pin doesnt have a valid URL.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
            })
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StudentTableViewCell
        let people = studentList[indexPath.row]
        labelFunction(label: cell.nameLabel, text: "\(people.firstName ?? " first Name" ) \(people.lastName ?? " last Name" )", color: UIColor(red: 0.001, green: 0.706, blue:0.903, alpha: 1))
        cell.linkLabel?.text = "\(people.mediaURL ?? "http://www.google.com")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentTableView.reloadData()
        studentTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let people = studentList[indexPath.row]
        sendToWebView(people)
        
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
            controller.lastName = lastName
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
    
    @IBAction func logOut(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UdacityClient.sharedInstance.logOut{ (parsedResults, error) in
            print(parsedResults!)
        }
    }
}



