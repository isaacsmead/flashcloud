//
//  FlashairConnection.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/25/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit

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

    //static let shared = FlashairConnection()
    var host: String = "flashair"
    var rootDir: String = "DCIM"
    var picList: [String] = []
    
    
    init(){
        let settings = NSDictionary(contentsOfFile: (Bundle.main.path(forResource: "FlashairSettings", ofType: "plist")!))!
        if let host = settings["host-name"] as? String{
            self.host = host
        }
        if let rootDir = settings["working-dir"] as? String{
            self.rootDir = rootDir
        }
    }
    
    typealias onFileListFunc = ([String],[String]) -> Void
    
    func getFileList(path: [String], callback: @escaping onFileListFunc){
        let urlStr = makeUrlString(host: host, command: cgiScripts.command.rawValue,
                                   args: [cgiArgs.getFileList.rawValue, makeDirQueryString(path: path)])
        Alamofire.request(urlStr, method: .get)
            .responseString { (response) in
                if(response.result.isSuccess == false){
                    NSLog(response.result.debugDescription)
                }
                if let list = response.result.value {
                    let (dirNames, imageNames) = self.parseFileList(list: list)
                    callback(dirNames, imageNames)
                }
        }
    }
    
    private func parseFileList(list: String) -> ([String],[String]){
        // https://www.flashair-developers.com/en/documents/api/commandcgi/#100
        let rows = list.split(separator: "\n")
        var dirs: [String] = []
        var imageNames: [String] = []
        for row in rows{
            let elements = row.split(separator: ",")
            if elements.count == 6 { // directory or file
                if ((Int(elements[3])! & 0x10) !=  0) { //directory
                    dirs.append(String(elements[1]))
                }
                // image TODO -- use regex
                else if (String(elements[1]).hasSuffix(".jpg") || String(elements[1]).hasSuffix(".jpg")){
                    imageNames.append(String(elements[1]))
                }
                
                dirs.append(String(elements[0]))
            }
        }
        return (dirs, imageNames)
    }
    
    
    func getThumbnail(path: String, callback: @escaping (String, UIImage) -> Void){
        let urlStr = makeUrlString(host: host, command: cgiScripts.thumbnail.rawValue, args: [path])
        
        Alamofire.request(urlStr, method: .get)
            .responseImage { response in
                debugPrint(response)
                
                print(response.request)
                print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    callback("foo", image)
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
    
    private func makeDirQueryString(path: [String]) ->String {
        let pathStr = path.joined(separator: "/")
        return ("DIR=\(rootDir)/\(pathStr)")
    }
}
