//
//  CreateGroupViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 14/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var allUsersTableView: UITableView!
    @IBOutlet weak var groupNameTF: UITextField!
    var dbRef : DatabaseReference?
    var allGroups = [[String: Any]]()
    var allUsers = [AppRocketUser]()
    let CELL_REUSE_IDENTIFIER = "AllUsersTableViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeDBRef()
        self.loadAllGroups()
        self.registerCellNibsForTableView()
        self.allUsersTableView.delegate = self
        self.allUsersTableView.dataSource = self
        self.fetchAllUsers()
    }

    func initializeDBRef(){
        self.dbRef = Database.database().reference()
    }
    func loadAllGroups(){
        self.dbRef?.child("Groups").observe(.value, with: { (snapshot) in
                   if(snapshot.exists()){
                        if let userData = snapshot.value as? [[String: String]]{
                               self.allGroups.removeAll()
                               for grp in userData{
                                   var grpDict = [String: Any]()
                                   for(key, value) in grp {
                                        print("Key: \(key), Value: \(value)")
                                        grpDict[key] = value
                                    }
                                    self.allGroups.append(grpDict)
                               }
                                           
                       }
                   }
                   else{
                       
                   }
               })
    }
    
    @IBAction func createGroup(_ sender: Any) {
        var groupExists = false
        for grp in self.allGroups{
            if self.groupNameTF.text! == (grp["name"] as! String){
                groupExists = true
            }
        }
        if(groupExists){
            
        }
        else{
            var participants = [String]()
            if let selectedPeopleIPs = self.allUsersTableView.indexPathsForSelectedRows{
                for ip in selectedPeopleIPs{
                    participants.append(self.allUsers[ip.row].username!)
                }
            }
            self.allGroups.append(["name": self.groupNameTF.text!, "participants":participants])
            self.dbRef?.child("Groups").setValue(self.allGroups)
            let chatVC = ChatViewController(chat: Chat())
            chatVC.receiverUsername = "Group\(self.groupNameTF.text!)"
            self.present(chatVC, animated: false, completion: nil)
        }
    }
    
    
    
    func registerCellNibsForTableView(){
        let nib = UINib(nibName: "AllUsersTableViewCell", bundle: nil)
        self.allUsersTableView.register(nib, forCellReuseIdentifier: self.CELL_REUSE_IDENTIFIER)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.allUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_REUSE_IDENTIFIER, for: indexPath) as! AllUsersTableViewCell
       
        cell.updateCell(user: self.allUsers[indexPath.row])
        return cell
    }
    
   
    func fetchAllUsers(){
         let ref = Database.database().reference()
                ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in // snapshot of users database
                if snapshot.exists()
                {
                if let userData = snapshot.value as? Dictionary<String,AnyObject>
                {
                for(key, value) in userData {
                    print("Key: \(key), Value: \(value)")
                    if let userValue = value as? Dictionary<String,AnyObject>  // list of users
                    {
                    if(Auth.auth().currentUser!.uid != key) {  // except current user
                     
                    let dict = NSMutableDictionary()
                     
            //        dict.setObject(key, forKey:"firebaseId" as NSCopying) // add firebaseId of users dict.setObject((userValue[“username”] as! NSDictionary).value(forKey: “First-name”)!, forKey: “First-name” as NsCopying) self.arrUserList.add(dict) // list of users added in array
                        let appRocketUser = AppRocketUser()
                        appRocketUser.username = userValue["username"] as? String
                        self.allUsers.append(appRocketUser)
                    }
                    }
                        
                        }
                    self.allUsersTableView.reloadData()
                        }
                    }
                else{
                        print("Snapshot does not exist!!")
                    }
                   
                })
    }

}
