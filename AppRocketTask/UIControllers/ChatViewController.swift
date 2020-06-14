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
    var receiverUsername: String = ""
    let arrMsg = NSMutableArray()
    var dbRef: DatabaseReference?
    var chatKeyStr = ""
    var messages = [[String: String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chat View Controller Loaded!!")
        
        self.initializeDBRef()
        self.initializeChats()

    }
    
    func initializeDBRef(){
        self.dbRef = Database.database().reference()
    }
 
    
    func initializeChats(){
       
        let key1 = (((Auth.auth().currentUser?.email!)!) + self.receiverUsername).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
        let key2 = (self.receiverUsername + (Auth.auth().currentUser?.email!)!).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")

        self.dbRef?.child("Chats").child(key1).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                print("Chats key1 exist")
                self.chatKeyStr = key1
                self.addChatObservers()
                self.loadChats()
            }
            else{
                print("Chats key1 do not exist")
                
                self.dbRef?.child("Chats").child(key2).observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    if(snapshot2.exists()){
                        print("Chats key2 exist")
                        self.chatKeyStr = key2
                        self.addChatObservers()
                        self.loadChats()
                    }
                    else{
                        print("Chats key2 do not exist")
                        self.chatKeyStr = key1
                        self.addChatObservers()
//                        self.addChatMessage(message: "Hello")
//                        let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (tmer) in
//                            self.addChatMessage(message: "Helloxx")
//                        }
                    }
                
                
                })
                
                
            }
        })
    }
    
     
    

    
    
    func loadChats(){
        self.dbRef?.child("Chats").child(self.chatKeyStr).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                print("Chats loaded!!")
                if let userData = snapshot.value as? [[String: String]]
                {
                        self.messages.removeAll()
                    for mseg in userData{
                    for(key, value) in mseg {
                            print("Key: \(key), Value: \(value)")
                            self.messages.append([key: "\(value)"])
                        }
                    
                    }
                    
//                    let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (tmer) in
//                        self.addChatMessage(message: "Helloxx")
//                    }
                }
                else{
                    print("\(snapshot.value)")
                }
            }
            else{
                print("Chats cannot be loaded!!")
            }
        })
        
    }
    

    func addChatObservers(){
        self.dbRef?.child("Chats").child(self.chatKeyStr).observe(.childAdded, with: { (snapshot) in
            if(snapshot.exists()){
                print("Observer successful!!")
                if let userData = snapshot.value as? Dictionary<String,AnyObject>
                {
                        for(key, value) in userData {
                            print("Key: \(key), Value: \(value)")
                        }
                }
                
            }
            else{
                print("Observer not successful!!")
            }
        })
    }
    
    
    func addChatMessage(message: String){
        print("Adding Chat message!!")
        var msgKey = self.getCurrentTimeStamp().replacingOccurrences(of: ".", with: "")
        msgKey = msgKey + "_" + "sender_" + ((Auth.auth().currentUser?.email!)!).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
        msgKey = msgKey + "_" + "receiver_" + self.receiverUsername.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
        self.messages.append([msgKey: message])
        self.dbRef?.child("Chats").child(self.chatKeyStr).setValue(self.messages)
    }
    
    func getCurrentTimeStamp() -> String {
               return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    
}
