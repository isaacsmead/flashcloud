//
//  ViewController.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/24/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


class ViewController: UIViewController {
    @IBOutlet weak var testText: UITextView!
    var manager : SessionManager? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: CustomServerTrustPoliceManager()
        )
        
        NotificationCenter
            .default
            .addObserver(self,
                       selector: #selector(self.updateText),
                       name: .picList,
                       object: nil)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func test() {
        
        FlashairConnection.shared.getFileList()

    }
    
    @objc func updateText(_ notification: NSNotification){
        if let list = notification.userInfo?["picList"] as? String{
            testText.text = list
            
        }
    }
    
    func login(){
        let url = URL(string: "https://isaac:trustno1@76.88.58.107/nextcloud/remote.php/dav/files/isaac/Photos")!
        //let url = URL(string: "https://76.88.58.107")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PROPFIND"
        
        //urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        manager!.request(urlRequest).responseString{ (response) in
                            if(response.result.isSuccess == false){
                                    print(response.result.debugDescription)
                            }
                            if let res = response.result.value {
                                self.testText.text = res
                            }
        }
        
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




