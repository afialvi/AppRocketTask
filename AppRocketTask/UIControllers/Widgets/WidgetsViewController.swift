//
//  WidgetsViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 15/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Alamofire

extension CLLocation {
func fetchAddress(completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
    CLGeocoder().reverseGeocodeLocation(self) {
        let palcemark = $0?.first
        var address = ""
        if let subThoroughfare = palcemark?.subThoroughfare {
            address = address + subThoroughfare + ","
        }
        if let thoroughfare = palcemark?.thoroughfare {
            address = address + thoroughfare + ","
        }
        if let locality = palcemark?.locality {
            address = address + locality + ","
        }
        if let subLocality = palcemark?.subLocality {
            address = address + subLocality + ","
        }
        if let administrativeArea = palcemark?.administrativeArea {
            address = address + administrativeArea + ","
        }
        if let postalCode = palcemark?.postalCode {
            address = address + postalCode + ","
        }
        if let country = palcemark?.country {
            address = address + country + ","
        }
        if address.last == "," {
            address = String(address.dropLast())
        }
        if address.count <= 0{
            address = "No address found!"
        }
        completion(address,$1)
       // completion("\($0?.first?.subThoroughfare ?? ""), \($0?.first?.thoroughfare ?? ""), \($0?.first?.locality ?? ""), \($0?.first?.subLocality ?? ""), \($0?.first?.administrativeArea ?? ""), \($0?.first?.postalCode ?? ""), \($0?.first?.country ?? "")",$1)
    }
    }
    
}


class WidgetsViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var latestMsgLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var calendarNextEventTime: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var calendarNextEventTitle: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var temperatureInDegreeCentigradeLbl: UILabel!
    
    @IBOutlet weak var topValue: UILabel!
    
    @IBOutlet weak var bottomValueLbl: UILabel!
    
    
    
    var dbRef: DatabaseReference?
    var allChats:[[String: [Message]]] = [[String: [Message]]]()
    let CALENDAR_API_KEY = "295328404642-725504bjgdknin7kk2j2v7lg9cga0kct.apps.googleusercontent.com"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeDBRef()
        self.updateTimeAndCalendarEvent()
        self.updateCurrentLocationAndWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadChats()
    }
    
    func updateTimeAndCalendarEvent(){
        let date = Date()
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        formatter.dateFormat = "HH:MM a"
        let currentTime: String = formatter.string(from: date)
        print("My Current Time is \(currentTime)")
        self.timeLbl.text = currentTime
        
        let dformatter = DateFormatter()
        dformatter.dateStyle = .long
        self.dateLbl.text = dformatter.string(from: date)
    }
    
    func updateCurrentLocationAndWeather(){
        if let loc = getCurrentLocation(){
        loc.fetchAddress(completion: { (address, error) in
            if error == nil{
                self.locationLbl.text = address
            }
            else{
                self.locationLbl.text = "Location not found"
            }
        })
        }
        else{
             self.locationLbl.text = "Location not found"
        }
        self.getWeatherUpdates()
    }
    
    @IBAction func viewChat(_ sender: Any) {
        var otherEmail = ""
        let lastMsg = self.allChats[self.allChats.count - 1]
        for (ki, val) in lastMsg{
             otherEmail = ki
        }
        let chatVC = ChatViewController(chat: Chat())
        chatVC.receiverUsername = otherEmail
        self.present(chatVC, animated: false, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.updateCurrentLocationAndWeather()
        
    }
    @IBAction func viewInbox(_ sender: Any) {
        let allChatsVC = AllChatsViewController()
        allChatsVC.allChats = self.allChats
        self.present(allChatsVC, animated: false, completion: nil)
    }
    
    
    
    
    func initializeDBRef(){
           self.dbRef = Database.database().reference()
    }
    
    
    
     func loadChats(){
        self.dbRef?.child("Chats").observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.allChats.removeAll()
                if let chats = snapshot.value as? [String: Any]{
                    for (key, value) in chats{
                            print("Chat key!! \(key)")
                        let email = (Auth.auth().currentUser?.email!)!.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
                        
                            if key.contains(email){
                                print("Current user chats exist")
                                var otheremail = ""
                                if key.starts(with: email){
                                   if let start = key.range(of: email)?.upperBound {
                                    
                                     otheremail = String(key[start..<key.endIndex])
                                    var msgs = [Message]()
                                    for v in value as! [[String: String]]{
                                        for(k, vak) in v{
                                            let m = Message()
                                            m.text = vak
                                            let splteddKey = k.split(separator: "_")
                                            m.timestamp = String(splteddKey[0])
                                            m.senderId = String(splteddKey[2])
                                            msgs.append(m)
                                            
                                        }
                                    }
                                    self.allChats.append([otheremail: msgs])
                                    
                                    }
                                }
                                else{
                                    if let endIndex = key.range(of: email)?.lowerBound {
                                         otheremail = String(key[..<endIndex])
                                        print(otheremail)
                                        var msgs = [Message]()
                                        for v in value as! [[String: String]]{
                                            for(k, vak) in v{
                                                let m = Message()
                                                m.text = vak
                                                let splteddKey = k.split(separator: "_")
                                                m.timestamp = String(splteddKey[0])
                                                m.senderId = String(splteddKey[2])
                                                msgs.append(m)
                                                
                                            }
                                        }
                                        print("Other Email: \(otheremail)")
                                        self.allChats.append([otheremail: msgs])
                                    }
                                }
                            }
                        
                    }
                    let lastMsg = self.allChats[self.allChats.count - 1]
                    for (ki, val) in lastMsg{
                        self.contactName.text = ki
                        self.latestMsgLbl.text = val[val.count - 1].text
                    }
                }
                else{
                    print("Chats have a different data type!!")
                }
            }
            else{
                
            }
        })
             
     }
         
    
    func getCurrentLocation() -> CLLocation?{
        var locationManager = CLLocationManager()

        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation?
//        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//        CLLocationManager.authorizationStatus() == .authorizedAlways) {
//            locationManager.delegate = self
//            locationManager.startUpdatingLocation()
//           currentLoc = locationManager.location
//           print("Latitude: \(currentLoc.coordinate.latitude)")
//           print("Longitude: \(currentLoc.coordinate.longitude)")
//        }
        return currentLoc
    }
    
    
    
    func getWeatherUpdates(){
        if let currLoc = getCurrentLocation(){
            let urlStr = "http://api.openweathermap.org/data/2.5/weather?lon=\(currLoc.coordinate.longitude)&lat=\(currLoc.coordinate.latitude)&appid=d07c03ab49c01c1f3dfcd8734acc75b1"

           


            NetworkUtils.sendRequest(url: urlStr, method: .get, parameters: nil) { (data, error) in
                if data == nil{
                    self.temperatureInDegreeCentigradeLbl.text = "-0C"
                    self.topValue.text = "-0"
                    self.bottomValueLbl.text = "-0"
                }
                else{
                    let alamofireData = data as! DataResponse<Any>
                    let dict = try! JSONSerialization.jsonObject(with: alamofireData.data!, options: []) as! [String: Any]
                    print("Dict: \(dict)")
                    let mainDict = dict["main"] as! [String: Any]
                    let currTemp = self.getCentigradeFromKelvin(temp: Int(mainDict["temp"] as! Double))
                    self.temperatureInDegreeCentigradeLbl.text = "\(currTemp)C"
                    
                    self.topValue.text = self.getCentigradeFromKelvin(temp: Int(mainDict["temp_max"] as! Double))
                    self.bottomValueLbl.text = self.getCentigradeFromKelvin(temp: Int(mainDict["temp_min"] as! Double))
                }
            }
        }
        else{
            self.temperatureInDegreeCentigradeLbl.text = "-0C"
            self.topValue.text = "-0"
            self.bottomValueLbl.text = "-0"
            
            
            
        }
        
    }
    
    func getCentigradeFromKelvin(temp: Int)->String{
        let centigradeTemp = temp - 273
        return String(centigradeTemp)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if locations.count > 0{
            
        }
    }
    
    
    
}
