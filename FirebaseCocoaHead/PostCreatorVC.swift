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
import Alamofire
import AlamofireImage

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
        postImageView.layer.masksToBounds = true
        
        setImageAndPostForUpdate()
        setRightBarButtonTitle()
        createDatabaseAndStorageRefs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resizeImage(image:UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //Creates references to database and storage
    func createDatabaseAndStorageRefs() {
        firebaseReference = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        firebaseStorageRef = storage.referenceForURL("gs://cocoahead-1f648.appspot.com")
    }
    
    //if this is a post update then set the image and text with the post to be updated.
    func setImageAndPostForUpdate() {
        if let post = post {
            Alamofire.request(.GET, post.photoURL)
                .responseImage { response in
                    
                if let image = response.result.value {
                    self.postImageView.image = image
                }
            }
            postTextView.text = post.text
        }
    }
    
    func setRightBarButtonTitle() {
        if post != nil {
            rightBarButton.title = "Update"
        } else {
            rightBarButton.title = "Save"
        }
    }
    
/*
     Used to upload the photo to Firebase. Once its uploaded and returns the
     downloadURL it then saves the post to the Firebase database
*/
    func uploadPhotoToFirebase(imageAsData: NSData) {
        let uniqueID = NSUUID().UUIDString

        let imagesRef = firebaseStorageRef.child("images/\(uniqueID).jpg")
        
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
    
/*
     Saves the post to Firebase. This is called in the
     uploadPhotoToFirebase once the photo is uploaded.
*/
    func savePostToFirebase(text: String, photoURL: String) {
        let childRef = firebaseReference.child("posts").childByAutoId()
        let post = ["text": text, "photoURL":photoURL]
        childRef.setValue(post)
    }
    
    //Update post on Firebase
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
            imageData = UIImageJPEGRepresentation(resizeImage(pickedImage, size: CGSizeMake(pickedImage.size.width/8, pickedImage.size.height/8)), 1.0)!
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
