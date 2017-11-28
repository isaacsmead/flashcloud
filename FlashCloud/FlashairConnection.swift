//
//  FlashairConnection.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/25/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import Foundation
import Alamofire

enum cgiScripts : String {
    case command = "command.cgi"
    case thumbnail = "thumbnail.cgi"
    case config = "config.cgi"
    case upload = "upload.cgi"
}

enum cgiArgs : String {
    case getFileList = "op=100"
    case getNumFiles = "op=101"
    case getUpdateStatus = "op=102"
    
}

extension Notification.Name {
    static let picList =  Notification.Name(rawValue:"pic-list")
}


class FlashairConnection  {

    static let shared = FlashairConnection()
    var host: String = "flashair"
    var workingDir: String = "DCIM"
    var picList: [String] = []
    
    
    private init(){
        let settings = NSDictionary(contentsOfFile: (Bundle.main.path(forResource: "FlashairSettings", ofType: "plist")!))!
        host = settings["host-name"]! as! String
        workingDir = settings["working-dir"] as! String
    }
    
    func getPicList(){
        let urlStr = makeUrlString(host: host, command: cgiScripts.command.rawValue, args: [cgiArgs.getFileList.rawValue, "DIR=\(workingDir)"])
        Alamofire.request(urlStr, method: .get)
            .responseString { (response) in
                if(response.result.isSuccess == false){
                    print(response.result.debugDescription)
                }
                if let list = response.result.value {
                    NotificationCenter.default.post(name: .picList, object: self, userInfo: ["picList": list])
                }
        }
    }
    

    private func makeUrlString(host: String, command: String, args: [String]) -> String{
        var url = "http://\(host)/\(command)"
        for (index, arg) in args.enumerated() {
            let connector = (( index == 0 ) ? "?" : "&")
            url = "\(url)\(connector)\(arg)"
        }
        return url
    }
}
