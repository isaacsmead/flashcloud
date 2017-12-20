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
    static let requestError =  Notification.Name(rawValue:"request-error")
}


class FlashairConnection  {
    
    /* function to request list of files from flash air */
    typealias onFileListFunc = ([String],[String]) -> Void
    
    class func getFileList(path: String, callback: @escaping onFileListFunc){
        let urlStr = makeUrlString(command: cgiScripts.command.rawValue,
                                   args: [cgiArgs.getFileList.rawValue, makeDirQueryString(path: path)])
        Alamofire.request(urlStr, method: .get)
            .responseString { (response) in
                if(response.result.isSuccess == false){
                    NSLog(response.result.debugDescription)
                }
                else if let list = response.result.value {
                    let (dirNames, imageNames) = self.parseFileList(list: list)
                    callback(dirNames, imageNames)
                }
        }
    }
    
    class func getThumbnail(fileName: String, path: String, callback: @escaping (String, UIImage) -> Void){
        let rootDir = Settings.shared[.flashairRoot]
        let fullPath =  (path == "") ? "\(rootDir)/\(fileName)" : "\(rootDir)/\(path)/\(fileName)"
        let urlStr = makeUrlString(command: cgiScripts.thumbnail.rawValue, args: [fullPath])
        
        Alamofire.request(urlStr, method: .get)
            .responseImage { response in
                if response.result.isFailure, let error = response.result.error{
                    NSLog("get thumbnail error:", error.localizedDescription)
                }
                else if let image = response.result.value {
                    callback(fileName, image)
                }
        }
    }
    //http://flashair/upload.cgi?DEL=/DCIM/100__TSB/DSC_100.JPG
    class func deleteFile(fileName: String, path: String, callback: @escaping (String) -> Void){
        let rootDir = Settings.shared[.flashairRoot]
        let fullPath =  (path == "") ? "DEL=/\(rootDir)/\(fileName)" : "DEL=/\(rootDir)/\(path)/\(fileName)"
        let urlStr = makeUrlString(command: cgiScripts.upload.rawValue, args: [fullPath])
        Alamofire.request(urlStr).responseString { (response) in
            if(response.result.isSuccess == false){
                NSLog(response.result.debugDescription)
            }
            else if let status = response.result.value {
                if(status == "SUCCESS"){
                    callback(fileName)
                }
            }
        }
    }
    
    class func getImage(fileName: String, path: String, callback: @escaping (String, UIImage) -> Void){
        let rootDir = Settings.shared[.flashairRoot]
        let fullPath =  (path == "") ? "\(rootDir)/\(fileName)" : "\(rootDir)/\(path)/\(fileName)"
        let urlStr = makeUrlString(command: "", args: [fullPath])
        
        Alamofire.request(urlStr, method: .get)
            .responseImage { response in
                if response.result.isFailure, let error = response.result.error{
                    NSLog("get image error:", error.localizedDescription)
                }
                else if let image = response.result.value {
                    callback(fileName, image)
                }
        }
    }
    
    private class func parseFileList(list: String) -> ([String],[String]){
        // https://www.flashair-developers.com/en/documents/api/commandcgi/#100
        let rows = list.split(separator: "\r\n")
        var dirs: [String] = []
        var imageNames: [String] = []
        for row in rows{
            let elements = row.split(separator: ",")
            if elements.count == 6 { // directory or file
                if ((Int(elements[3])! & 0x10) !=  0) { //directory
                    dirs.append(String(elements[1]))
                }
                    // image TODO -- use regex for various image types
                else if (String(elements[1]).hasSuffix(".JPG") || String(elements[1]).hasSuffix(".jpg")){
                    imageNames.append(String(elements[1]))
                }
                
                
            }
        }
        return (dirs, imageNames)
    }

    private class func makeUrlString(command: String, args: [String]) -> String{
        let host = Settings.shared[.flashairHost]
        var url = "http://\(host)/\(command)"
        for (index, arg) in args.enumerated() {
            let connector = (( index == 0 ) ? "?" : "&")
            url = "\(url)\(connector)\(arg)"
        }
        return url
    }
    
    private class func makeDirQueryString(path: String) ->String {
        let rootDir = Settings.shared[.flashairRoot]
        if path == "" {
            return ("DIR=\(rootDir)")
        }
        return ("DIR=\(rootDir)/\(path)")
    }
}
