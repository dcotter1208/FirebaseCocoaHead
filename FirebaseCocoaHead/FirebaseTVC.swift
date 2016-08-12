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
        
        testChildChanged()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Firebase Methods
    
    //Add to Firebase
    func saveTextToFirebase(text: String) {

        let childRef = firebaseReference.child("names").childByAutoId()
        
        let person = ["name": text]

        childRef.setValue(person)
    }
    
    //Remove from Firebase
    func deleteValueForChild(child: String, childKey: String) {
        
        let childToRemove = firebaseReference.child(child).child(childKey)
        
        childToRemove.removeValue()
        
    }
    
    //Query from Firebase
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
    
    //Update on Firebase
    func updateChildValue(personToUpdate: Person, updatedName: String) {
        
        let childRef = firebaseReference.child("names")

        let childUpdates = [personToUpdate.snapshotKey:["name":updatedName]]
        
        childRef.updateChildValues(childUpdates)
        
    }
    
    //Accepts a query to listen for a change.
    func listenForChildNodeChanges(query: FIRDatabaseQuery, completion:(result:FIRDataSnapshot)-> Void) {
        
//        let childRef = firebaseReference.child("names")

        query.observeEventType(.ChildChanged) {
            (snapshot) in
            completion(result: snapshot)
        }
    }
    
    //MARK: Helper Methods
    func alertWithTextEntry(title: String, completion:(text: String)-> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let save = UIAlertAction(title: "Save", style: .Default) { (action) in
            
            let textfield = alertController.textFields![0] as UITextField
            
            if let text = textfield.text {
                completion(text: text)
            }
        }
        
        alertController.addAction(save)
        
        presentViewController(alertController, animated: true, completion: nil)

        
    }

    
    func testChildChanged() {
        let childRef = self.firebaseReference.child("names")
        childRef.observeEventType(.ChildChanged, withBlock: { (snapshot: FIRDataSnapshot) in
            
            let updatedPerson = Person(name: snapshot.value!["name"] as! String, snapshotKey: snapshot.key)
            
            for person in self.people {
                if person.snapshotKey == updatedPerson.snapshotKey {
                    person.name = updatedPerson.name
                }
            }
            self.tableView.reloadData()
        })
    }
    
    //MARK: TableView
    
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let personToUpdate = people[indexPath.row]
        
        alertWithTextEntry("Update Name") { (text) in
            self.updateChildValue(personToUpdate, updatedName: text)

        }
        
    }
    
    //MARK: IBActions

    @IBAction func addButtonPressed(sender: AnyObject) {
        
        alertWithTextEntry("Enter Name") { (text) in
            self.saveTextToFirebase(text)

        }
        
    }

}
