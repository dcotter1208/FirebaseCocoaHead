//
//  FirebaseTVC.swift
//  FirebaseCocoaHead
//
//  Created by Cotter on 8/12/16.
//  Copyright © 2016 Cotter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import AlamofireImage

class FirebaseTVC: UITableViewController {

    var posts = [Post]()
    var firebaseReference = FIRDatabaseReference()
    var postToUpdate: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseReference = FIRDatabase.database().reference()
        queryPostsFromFirebase()
        listenForChildNodeChanges()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        postToUpdate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadPostImageFromFirebase(URL: String, completion:(result: UIImage) -> Void) {
        Alamofire.request(.GET, URL)
            .responseImage { response in

            if let image = response.result.value {
                completion(result: image)
            }
        }
    }
    
    
    //MARK: Firebase Methods

    //Remove from Firebase
    func deleteValueForChild(child: String, childKey: String) {
        let childToRemove = firebaseReference.child(child).child(childKey)
        childToRemove.removeValue()
    }
    
    //Query from Firebase
    func queryPostsFromFirebase() {
        let childRef = firebaseReference.child("posts")
        
        childRef.observeEventType(.ChildAdded) {
            (snapshot: FIRDataSnapshot) in

            if let value = snapshot.value {
                let post = Post(text: value["text"] as! String, photoURL: value["photoURL"] as! String, snapshotKey: snapshot.key)
                self.posts.append(post)
                self.tableView.reloadData()
            }
        }
    }

    //Listens for changes to a post.
    func listenForChildNodeChanges() {
        let childRef = self.firebaseReference.child("posts")
        childRef.observeEventType(.ChildChanged, withBlock: { (snapshot: FIRDataSnapshot) in
            let updatedPost = Post(text: snapshot.value!["text"] as! String, photoURL: snapshot.value!["photoURL"] as! String, snapshotKey: snapshot.key)
            
            for post in self.posts {
                if post.snapshotKey == updatedPost.snapshotKey {
                    post.text = updatedPost.text
                    post.photoURL = updatedPost.photoURL
                }
            }
            self.tableView.reloadData()
        })
    }
    
    //MARK: TableView

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let cellImageView = cell.contentView.viewWithTag(200) as? UIImageView
        let cellTextView = cell.contentView.viewWithTag(100) as? UITextView
        let post = posts[indexPath.row]
        cellTextView?.text = post.text
        
        downloadPostImageFromFirebase(post.photoURL) { (result) in
            cellImageView!.image = result
        }

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteValueForChild("posts", childKey: posts[indexPath.row].snapshotKey)
            posts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        postToUpdate = posts[indexPath.row]
        self.performSegueWithIdentifier("postCreatorSegue", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destionationVC = segue.destinationViewController as? PostCreatorVC
        destionationVC?.post = postToUpdate
    }
    
}
