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

class FirebaseTVC: UITableViewController {

    var people = [Person]()
    var firebaseReference = FIRDatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseReference = FIRDatabase.database().reference()

        queryNamesFromFirebase()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveTextToFirebase(text: String) {

        let childRef = firebaseReference.child("names").childByAutoId()
        
        let person = ["name": text]

        childRef.setValue(person)
    }
    
    func deleteValueForChild(child: String, childKey: String) {
        
        let childToRemove = firebaseReference.child(child).child(childKey)
        
        childToRemove.removeValue()
        
    }
    
    func queryNamesFromFirebase() {

        let childRef = firebaseReference.child("names")
        
        childRef.observeEventType(.ChildAdded) {
            (snapshot: FIRDataSnapshot) in

            if let value = snapshot.value {
                let person = Person(name: value["name"] as! String, snapshotKey: snapshot.key)
                self.people.append(person)
                self.tableView.reloadData()
            }
        }
    }
    
    
    func alertWithTextEntry() {
        let alertController = UIAlertController(title: "Enter Name", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let save = UIAlertAction(title: "Save", style: .Default) { (action) in
            
            let textfield = alertController.textFields![0] as UITextField
            
            if let text = textfield.text {
                self.saveTextToFirebase(text)
            }
        }
        
        alertController.addAction(save)
        
        presentViewController(alertController, animated: true, completion: nil)

        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel?.text = people[indexPath.row].name

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteValueForChild("names", childKey: people[indexPath.row].snapshotKey)
            people.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


    @IBAction func addButtonPressed(sender: AnyObject) {
        
        alertWithTextEntry()
        
    }

}
