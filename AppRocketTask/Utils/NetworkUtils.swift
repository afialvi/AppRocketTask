//
//  NetworkUtils.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 16/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import Alamofire

class NetworkUtils: NSObject {
    
    static func sendRequest(url: String, method: HTTPMethod, parameters:[String: Any]?, completion: @escaping (_ data: Any?, _ error: Error?) -> Void){
        let requestURL = URL(string: url)!
        var headers = HTTPHeaders()
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(requestURL, method: method, parameters: parameters, encoding: Alamofire.URLEncoding() , headers: headers).responseJSON { (jsonResp) in
            print(jsonResp)
            if(jsonResp == nil){
                completion(nil, nil)
            }
            else{
                completion(jsonResp, nil)
            }
        }
//        response { (defaultDataResponse) in
//
//            if (defaultDataResponse == nil){
//                completion(nil, nil)
//            }
//            else{
//                completion(defaultDataResponse, nil)
//            }
//        }
    }
}
