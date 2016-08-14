//
//  Post.swift
//  FirebaseCocoaHead
//
//  Created by Cotter on 8/12/16.
//  Copyright © 2016 Cotter. All rights reserved.
//

import Foundation

class Post {
    var text:String
    var photoURL: String
    let snapshotKey:String
    
    init(text:String, photoURL: String, snapshotKey: String) {
        self.text = text
        self.photoURL = photoURL
        self.snapshotKey = snapshotKey
    }
    
}
