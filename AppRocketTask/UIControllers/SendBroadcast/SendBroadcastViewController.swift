//
//  SendBroadcastViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 16/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class SendBroadcastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var broadcastMessageTextView: UITextView!
    @IBOutlet weak var selectContactsTableView: UITableView!
    var dbRef : DatabaseReference?
    var allUsers = [AppRocketUser]()
    let CELL_REUSE_IDENTIFIER = "AllUsersTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeDBRef()
        self.registerCellNibsForTableView()
        self.selectContactsTableView.delegate = self
        self.selectContactsTableView.dataSource = self
        self.fetchAllUsers()
    }
    func getCurrentTimeStamp() -> String {
               return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    func initializeDBRef(){
        self.dbRef = Database.database().reference()
    }
    func registerCellNibsForTableView(){
         let nib = UINib(nibName: "AllUsersTableViewCell", bundle: nil)
         self.selectContactsTableView.register(nib, forCellReuseIdentifier: self.CELL_REUSE_IDENTIFIER)
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
                     self.selectContactsTableView.reloadData()
                         }
                     }
                 else{
                         print("Snapshot does not exist!!")
                     }
                    
                 })
     }

    @IBAction func sendBroadcast(_ sender: Any) {
        var participants = [String]()
        if let selectedPeopleIPs = self.selectContactsTableView.indexPathsForSelectedRows{
            for ip in selectedPeopleIPs{
                participants.append(self.allUsers[ip.row].username!)
            }
        }
        if participants.count > 0{
            let email = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
            var chatStr = "Broadcast\(email)"
            for p in participants{
                chatStr = chatStr + (p.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: ""))
            }
            var msgKey = self.getCurrentTimeStamp().replacingOccurrences(of: ".", with: "")
            msgKey = msgKey + "_" + "sender_" + ((Auth.auth().currentUser?.email!)!).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
            msgKey = msgKey + "_" + "receiver_" + chatStr.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
            self.dbRef?.child("Chats").child(chatStr).setValue([[msgKey: self.broadcastMessageTextView.text!]])
            self.dismiss(animated: true, completion: nil)
        }
    }
}
