//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Ryan Berry on 12/1/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
