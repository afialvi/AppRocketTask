//
//  ChatViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 13/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class ChatViewController: UIViewController {

    var users = [AppRocketUser]()
    var dict:NSDictionary!
    let arrMsg = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chat View Controller Loaded!!")
        self.updateChatUsers()
        for usr in self.users{
            print("User: \(usr.username!)")
        }
    }
    
    func initialization(){
        let database = Database.database().reference()
        database.child("Chats").child(Auth.auth().currentUser!.uid).child("\(String(describing: dict.object(forKey: "firebaseId")!))").observe(.childAdded) { (snapshot) in
            
            let components = snapshot.key.components(separatedBy: "_")
            let dictMsg = NSMutableDictionary()
            dictMsg.setObject(components[1], forKey: "SenderId" as NSCopying)
            dictMsg.setObject(components[2], forKey: "ReceiverId" as NSCopying)
            dictMsg.setObject(snapshot.value!, forKey: "Message" as NSCopying)
    
        }
    }
    
    func updateChatUsers(){
       
         
        }
    
    func getCurrentTimeStamp() -> String {
               return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    func sendMsg(textMsg: String){
        let database = Database.database().reference()
        let str =  "\(String(describing: self.getCurrentTimeStamp().replacingOccurrences(of: ".", with: "")))" + "_" + "\(String(describing: Auth.auth().currentUser!.uid))" + "_" + "\(String(describing: dict.object(forKey: "firebaseId")!))"
        
        database.child("Chats").child("\(String(describing: dict.object(forKey: "firebaseId")!))").child(Auth.auth().currentUser!.uid).updateChildValues([str : textMsg])
        
        database.child("Chats").child(Auth.auth().currentUser!.uid).child("\(String(describing: dict.object(forKey: "firebaseId")!))").updateChildValues([str : textMsg])
        
    }
    
    
}
