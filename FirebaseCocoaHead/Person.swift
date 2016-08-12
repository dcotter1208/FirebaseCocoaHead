//
//  Person.swift
//  FirebaseCocoaHead
//
//  Created by Cotter on 8/12/16.
//  Copyright © 2016 Cotter. All rights reserved.
//

import Foundation

class Person {
    var name:String
    let snapshotKey:String
    
    init(name:String, snapshotKey: String) {
        self.name = name
        self.snapshotKey = snapshotKey
    }
    
}
