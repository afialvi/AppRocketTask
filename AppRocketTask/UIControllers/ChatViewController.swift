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
import NoChat

class ChatViewController: NOCChatViewController, UINavigationControllerDelegate, MessageManagerDelegate, MMChatInputTextPanelDelegate, MMTextMessageCellDelegate {
    var messageManager = MessageManager.manager
    var layoutQueue = DispatchQueue(label: "com.little2s.nochat-example.mm.layout", qos: DispatchQoS(qosClass: .default, relativePriority: 0))

    
    let chat: Chat
    var users = [AppRocketUser]()
    var dict:NSDictionary!
    var receiverUsername: String = ""
    let arrMsg = NSMutableArray()
    var dbRef: DatabaseReference?
    var chatKeyStr = ""
    var messages = [[String: String]]()
    
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        isInverted = false
        chatInputContainerViewDefaultHeight = 50
        messageManager.addDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageManager.removeDelegate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chat View Controller Loaded!!")
        backgroundView?.image = UIImage(named: "MMWallpaper")!
        navigationController?.delegate = self
        let rightItem = UIBarButtonItem(image: UIImage(named: "MMUserInfo"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightItem
        title = chat.title
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
                
                self.loadChats()
            }
            else{
                print("Chats key1 do not exist")
                
                self.dbRef?.child("Chats").child(key2).observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    if(snapshot2.exists()){
                        print("Chats key2 exist")
                        self.chatKeyStr = key2
//                        self.addChatObservers()
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
                    var msgObjs = [Message]()
                    for mseg in userData{
                    
                    for(key, value) in mseg {
                            print("Key: \(key), Value: \(value)")
                            self.messages.append([key: "\(value)"])
                        let m = Message()
                        m.text = value
                        let splteddKey = key.split(separator: "_")
                        m.timestamp = String(splteddKey[0])
                        m.senderId = String(splteddKey[2])
                        let currentUserEmail = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
                        if(m.senderId == currentUserEmail){
                            m.isOutgoing = true
                        }
                        else{
                             m.isOutgoing = false
                        }
                        msgObjs.append(m)
                        }
                    
                    }
                    self.addMessages(msgObjs, scrollToBottom: true, animated: false)
                    
//                    let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (tmer) in
//                        self.addChatMessage(message: "Helloxx")
//                    }
                }
                else{
                    print("\(snapshot.value)")
                }
                self.addChatObservers()
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
                    for (key, value) in userData{
                        print("Obs Key: \(key)")
                        print("Obs Value: \(value)")
                        var msgExists = false
                        for ms in self.messages{
                            for (k,v) in ms{
                                if k == key{
                                   msgExists = true
                                }
                                
                            }
                        }
                        if(!msgExists){
                             var msgObjs = [Message]()
                            for(key, value) in userData {
                                print("Key: \(key), Value: \(value)")
                                let m = Message()
                                m.text = value as! String
                                let splteddKey = key.split(separator: "_")
                                m.timestamp = String(splteddKey[0])
                                m.senderId = String(splteddKey[2])
                                let currentUserEmail = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
                               if(m.senderId == currentUserEmail){
                                     m.isOutgoing = true
                                }
                                else{
                                     m.isOutgoing = false
                                   }
                                   msgObjs.append(m)
                                 }
                                self.addMessages(msgObjs, scrollToBottom: true, animated: false)
                            self.messages.append([key: value as! String])
                        }
                        
                    }
                    
//                    var msgObjs = [Message]()
//                        for(key, value) in userData {
//                            print("Key: \(key), Value: \(value)")
//                            let m = Message()
//                            m.text = value as! String
//                            let splteddKey = key.split(separator: "_")
//                            m.timestamp = String(splteddKey[0])
//                            m.senderId = String(splteddKey[2])
//                            let currentUserEmail = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
//                            if(m.senderId == currentUserEmail){
//                                m.isOutgoing = true
//                            }
//                            else{
//                                 m.isOutgoing = false
//                            }
//                            msgObjs.append(m)
//                        }
//                    self.addMessages(msgObjs, scrollToBottom: true, animated: false)
                    
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
        let m = Message()
         m.text = message
         let splteddKey = msgKey.split(separator: "_")
         m.timestamp = String(splteddKey[0])
         m.senderId = String(splteddKey[2])
         let currentUserEmail = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
        if(m.senderId == currentUserEmail){
              m.isOutgoing = true
         }
         else{
              m.isOutgoing = false
            }
        self.addMessages([m], scrollToBottom: true, animated: false)
    }
    
    func getCurrentTimeStamp() -> String {
               return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    
//////////// Chat UI Methods ////////////
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        if type == "Text" {
            return MMTextMessageCellLayout.self
        } else if type == "Date" {
            return MMDateMessageCellLayout.self
        } else if type == "System" {
            return MMSystemMessageCellLayout.self
        } else {
            return nil
        }
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        return MMChatInputTextPanel.self
    }
    
    override func registerChatItemCells() {
        collectionView?.register(MMTextMessageCell.self, forCellWithReuseIdentifier: MMTextMessageCell.reuseIdentifier())
        collectionView?.register(MMDateMessageCell.self, forCellWithReuseIdentifier: MMDateMessageCell.reuseIdentifier())
        collectionView?.register(MMSystemMessageCell.self, forCellWithReuseIdentifier: MMSystemMessageCell.reuseIdentifier())
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView && scrollView.isTracking {
            inputPanel?.endInputting(true)
        }
    }
    
    // MARK: MMChatInputTextPanelDelegate
    
    func didInputTextPanelStartInputting(_ inputTextPanel: MMChatInputTextPanel) {
        if isScrolledAtBottom() == false {
            scrollToBottom(animated: true)
        }
    }
    
    func inputTextPanel(_ inputTextPanel: MMChatInputTextPanel, requestSendText text: String) {
        let msg = Message()
        msg.text = text
        sendMessage(msg)
    }
    
    // MARK: MMTextMessageCellDelegate
    
    func didTapLink(cell: MMTextMessageCell, linkInfo: [AnyHashable: Any]) {
        inputPanel?.endInputting(true)
        
        guard let command = linkInfo["command"] as? String else { return }
        let msg = Message()
        msg.text = command
//        sendMessage(msg)
    }
    
    // MARK: MessageManagerDelegate
    
    func didReceiveMessages(messages: [Message], chatId: String) {
        DispatchQueue.main.async {
            if self.isViewLoaded == false { return }
            
            if chatId == self.chat.chatId {
                self.addMessages(messages, scrollToBottom: true, animated: true)
            }
        }
    }
    
    
    private func sendMessage(_ message: Message) {
           message.isOutgoing = true
           message.senderId = User.currentUser.userId
           message.deliveryStatus = .Read
           
//           addMessages([message], scrollToBottom: true, animated: true)
        addChatMessage(message: message.text)
           messageManager.sendMessage(message, toChat: chat)
       }
       
       private func addMessages(_ messages: [Message], scrollToBottom: Bool, animated: Bool) {
           var width: CGFloat = 0
           if Thread.isMainThread {
               width = self.cellWidth
           } else {
               DispatchQueue.main.sync {
                   width = self.cellWidth
               }
           }
           
           layoutQueue.async { [weak self] in
               guard let strongSelf = self else { return }
               let count = strongSelf.layouts.count
               let indexes = IndexSet(integersIn: count..<count+messages.count)
               
               var layouts = [NOCChatItemCellLayout]()
               for message in messages {
                let layout = strongSelf.createLayout(with: message)!
                   layouts.append(layout)
               }
               
               DispatchQueue.main.async {
                   strongSelf.insertLayouts(layouts, at: indexes, animated: animated)
                   if scrollToBottom {
                       strongSelf.scrollToBottom(animated: animated)
                   }
               }
           }
       }
}
