//
//  PostCreatorVC.swift
//  FirebaseCocoaHead
//
//  Created by Cotter on 8/14/16.
//  Copyright © 2016 Cotter. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage


class PostCreatorVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var firebaseStorageRef = FIRStorageReference()
    var firebaseReference = FIRDatabaseReference()
    var storage = FIRStorage()
    var imageData = NSData()
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let post = post {
            let imageData = NSData(contentsOfURL: NSURL(string: post.photoURL)!)
            postImageView.image = UIImage(data: imageData!)
            postTextView.text = post.text
        }
        
        if post != nil {
            rightBarButton.title = "Update"
        } else {
            rightBarButton.title = "Save"
        }
        
        postImageView.layer.masksToBounds = true
        
        firebaseReference = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        firebaseStorageRef = storage.referenceForURL("gs://cocoahead-1f648.appspot.com")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadPhotoToFirebase(imageAsData: NSData) {
        let uniqueID = NSUUID().UUIDString
        let newImageReference = "images/\(uniqueID).jpg"
        let imagesRef = firebaseStorageRef.child(newImageReference)
        
        let uploadTask = imagesRef.putData(imageAsData, metadata: nil) { (metaData:FIRStorageMetadata?, error: NSError?) in
            if (error != nil) {
                print(error)
            } else {
                if let metaDataDownloadURL = metaData?.downloadURL() {
                    
                    if self.post != nil {
                        if let postToUpdate = self.post {
                            self.updateChildValue(postToUpdate, updatedText: self.postTextView.text, updatedPhotoURL: metaDataDownloadURL.absoluteString)
                        }
                    } else {
                        self.savePostToFirebase(self.postTextView.text, photoURL: metaDataDownloadURL.absoluteString)
                    }
                }
            }
        }
        
        uploadTask.resume()
        
    }
    
    func savePostToFirebase(text: String, photoURL: String) {
        
        let childRef = firebaseReference.child("posts").childByAutoId()
 
        let post = ["text": text, "photoURL":photoURL]
        
        childRef.setValue(post)
    }
    
    //Update on Firebase
    func updateChildValue(postToUpdate: Post, updatedText: String, updatedPhotoURL: String) {
        
        let childRef = firebaseReference.child("posts")
        
        let childUpdates = [postToUpdate.snapshotKey:["text":updatedText, "photoURL": updatedPhotoURL]]
        
        childRef.updateChildValues(childUpdates)
        
    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            postImageView.image = pickedImage
            imageData = UIImageJPEGRepresentation(pickedImage, 1.0)!
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    
    @IBAction func photoTapGesturePressed(sender: AnyObject) {
        
        presentCamera()
        
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        
        uploadPhotoToFirebase(imageData)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }


}
