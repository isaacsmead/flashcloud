//
//  CloudConnection.swift
//  FlashCloud
//
//  Created by Isaac Smead on 12/19/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit

extension Notification.Name {
    static let nextCloudError =  Notification.Name(rawValue:"nextcloud-error")
}


class CloudConnection {
    
    static let shared = CloudConnection()
    let manager : SessionManager
    private init () {
        manager = SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: CustomServerTrustPoliceManager()
        )
    }

    func uploadImageData(data: Data, fileName: String, callBack: @escaping (String) -> Void) {
        //let data = UIImageJPEGRepresentation(image, 1)!
        let headers = [ "Content-Type": "image/jpeg" ]
        let url = getUploadUrl(fileName: fileName)

        manager.upload(data, to: url, method: .put, headers: headers)
            .validate()
            .responseString { response in
                if(response.result.isSuccess){
                    callBack(fileName)
                }
                else {
                    let description = response.result.error?.localizedDescription ?? "unknown error"
                    NSLog("uploadImageData Error \(description)")
                    NotificationCenter.default.post(name: .flashAirError, object: self,
                                                    userInfo: ["message": "Failed to upload image"])
                }
            
        }
    }
    
    private func getUploadUrl(fileName: String) -> String{
        let host = Settings.shared[.nextcloudHost]
        let user = Settings.shared[.nextcloudUser]
        let root = Settings.shared[.nextcloudRoot]
        let pass = Settings.shared[.nextcloudPassword]
        let target = Settings.shared[.nextcloudTarget]
        return "https://\(user):\(pass)@\(host)/\(root)/\(user)/\(target)/\(fileName)"
    }
}

class CustomServerTrustPoliceManager : ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
    
    public init() {
        super.init(policies: [:])
    }
}
