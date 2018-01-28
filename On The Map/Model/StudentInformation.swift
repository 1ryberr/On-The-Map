//
//  StudentInformation.swift
//  On The Map
//
//  Created by Ryan Berry on 11/27/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import Foundation
struct StudentInformation {
    var  latitude : Double!
    var longitude : Double!
    var firstName: String!
    var lastName: String!
    var mediaURL: String!
    var objectId: String! 
    
    init?(dict: [String: AnyObject]){
        mediaURL = dict["mediaURL"] as? String
        firstName = dict["firstName"] as? String
        lastName = dict["lastName"] as? String
        objectId = dict["objectId"] as? String
        latitude = dict["latitude"] as? Double
        longitude = dict["longitude"] as? Double
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var person = [StudentInformation]()
        for result in results {
            person.append(StudentInformation(dict: result)!)
        }
        return person
    }
    
}










