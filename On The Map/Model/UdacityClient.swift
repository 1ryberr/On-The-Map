//
//  UdacityClient.swift
//  On The Map
//
//  Created by Ryan Berry on 12/1/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit

class UdacityClient: NSObject{
    
    static let sharedInstance = UdacityClient()
    private override init() {}
    
    func getStudentInfo(url: String, completionHandlerForPOST: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.timeoutInterval = 10.0
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
          
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
         
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let personInfo = parsedResult!["results"] as? [[String:AnyObject]]!{
                let students = StudentInformation.studentsFromResults(personInfo)
                completionHandlerForPOST(students, nil)
            }else{
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentInfo"]))
            }
            
        }
        task.resume()
        return task
    }
    
    func postStudentLocation(url: String,jsonBodyString: String ,completionHandlerForPOST: @escaping (_ result: String?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBodyString.data(using: .utf8)
        request.timeoutInterval = 10.0
        
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "postStudentLocation", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
          
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
               sendError("Your request returned a status code other than 2xx!")
                return
            }
            
       
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
         
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
               completionHandlerForPOST(nil, NSError(domain: "postStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey : error]))
                return
            }
            
            guard let objectID = parsedResult!["objectId"] as? String else {
                 sendError("Object ID error")
                return
            }
               completionHandlerForPOST(objectID ,nil)
            
        }
        task.resume()
        return task
    }
    
    
    func updateStudentLocation(url: String, jsonBodyString: String ,completionHandlerForPOST: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        let url = URL(string: url)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBodyString.data(using: .utf8)
        request.timeoutInterval = 10.0
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            completionHandlerForPOST(data, nil)
        }
        task.resume()
        return task
    }
    
    
    func getSessionID(userName: String, passWord: String, completionHandlerForPOST: @escaping (_ result: String?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        let uName = "\"\(userName)\""
        let pword = "\"\(passWord)\""
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody =  "{\"udacity\": {\"username\": \(uName),\"password\": \(pword)}}".data(using: .utf8)
        request.timeoutInterval = 10.0
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
        
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let sessionID = parsedResult!["session"] as? [String: AnyObject]else{
                sendError("Could not get data from session id")
                return
            }
            guard let id = sessionID["id"] as? String else {
                sendError("id error ")
                return
            }
            completionHandlerForPOST(id, nil)
        }
        task.resume()
        return task
    }
    
    
    func logOut(completionHandlerForPOST: @escaping (_ parsedResult: [String: AnyObject]?, _ error: NSError?)-> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 10.0
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data!)'")
                return
            }

             completionHandlerForPOST(parsedResult, nil)
        }
        
        task.resume()
        return task
    }
    
    func getPublicUserData(){
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/1549851310_dd50d0707039a2a7501657d908ca1555")!)
            request.timeoutInterval = 10.0
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
          //  print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
        
    }
    
    func jsonBodyString(dict: [String: String]) -> String{
        
        let first = "firstName"
        let last = "lastName"
        let place1 = "mapString"
        let link1 = "link"
        
        let jsonBody: String
        jsonBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(dict[first]!)\" , \"lastName\": \"\(dict[last]!)\",\"mapString\": \"\(dict[place1]!)\", \"mediaURL\": \"\(dict[link1]!)\",\"latitude\": \(dict["latitude"]!), \"longitude\": \(dict["longitude"]!)}"
        return jsonBody
        
    }
    
}
