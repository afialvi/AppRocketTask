//
//  AllChatsViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 15/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit

class AllChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var allChatsTableView: UITableView!
    var allChats:[[String: [Message]]]?
     let CELL_REUSE_IDENTIFIER = "ChatsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellNibsForTableView()
        self.allChatsTableView.delegate = self
        self.allChatsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    func registerCellNibsForTableView(){
        let nib = UINib(nibName: "ChatsTableViewCell", bundle: nil)
        self.allChatsTableView.register(nib, forCellReuseIdentifier: self.CELL_REUSE_IDENTIFIER)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.allChats?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_REUSE_IDENTIFIER, for: indexPath) as! ChatsTableViewCell
        var otherUser = ""
        var latestMsg = ""
        for (k,v) in self.allChats![indexPath.row]{
            otherUser = k
            latestMsg = v[v.count - 1].text
        }
        cell.updateCell(contact: otherUser, msg: latestMsg)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let chatVC = ChatViewController(chat: Chat())
        var otherUser = ""
        
        for (k,v) in self.allChats![indexPath.row]{
            otherUser = k
        }
        chatVC.receiverUsername = otherUser
        self.present(chatVC, animated: false, completion: nil)
    }
    @IBAction func createNewChat(_ sender: Any) {
        self.present(AllUsersViewController(), animated: false, completion: nil)
    }
}
