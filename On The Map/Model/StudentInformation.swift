//
//  StudentInformation.swift
//  On The Map
//
//  Created by Ryan Berry on 11/27/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import Foundation


struct Results: Decodable {
    
    let objectId : String?
    let latitude : Double?
    let longitude : Double?
    let firstName: String?
    let lastName: String?
    let mediaURL: String?
    
}
