//
//  AllUsersViewController.swift
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

class AllUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var allUsersTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var allUsers = [AppRocketUser]()
    var usersSearched = [AppRocketUser]()
    var userSearchText = ""
    let CELL_REUSE_IDENTIFIER = "AllUsersTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellNibsForTableView()
        self.allUsersTableView.delegate = self
        self.allUsersTableView.dataSource = self
        self.searchBar.delegate = self
        self.fetchAllUsers()
        
        // Do any additional setup after loading the view.
        
    }

    func registerCellNibsForTableView(){
        let nib = UINib(nibName: "AllUsersTableViewCell", bundle: nil)
        self.allUsersTableView.register(nib, forCellReuseIdentifier: self.CELL_REUSE_IDENTIFIER)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userSearchText.count > 0 ? self.usersSearched.count : self.allUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_REUSE_IDENTIFIER, for: indexPath) as! AllUsersTableViewCell
        if(self.userSearchText.count > 0){
             cell.updateCell(user: self.usersSearched[indexPath.row])
        }
        else{
            cell.updateCell(user: self.allUsers[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let chatVC = ChatViewController(chat: Chat())
        if self.userSearchText.count > 0{
            chatVC.receiverUsername = self.usersSearched[indexPath.row].username!
        }
        else{
            chatVC.receiverUsername = self.allUsers[indexPath.row].username!
        }
        self.present(chatVC, animated: false, completion: nil)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.usersSearched = [AppRocketUser]()
        self.userSearchText = searchText
            for usr in allUsers{
                if (usr.username?.contains(searchText))!{
                    self.usersSearched.append(usr)
                }
            }
            self.allUsersTableView.reloadData()
    
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
    @IBAction func createNewGroup(_ sender: Any) {
        let cng = CreateGroupViewController()
        self.present(cng, animated: false, completion: nil)
    }
    
    @IBAction func sendBroadcast(_ sender: Any) {
        let bvc = SendBroadcastViewController()
        self.present(bvc, animated: false, completion: nil)
    }
}
