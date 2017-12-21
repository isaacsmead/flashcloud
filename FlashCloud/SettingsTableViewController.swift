//
//  SettingsTableViewController.swift
//  FlashCloud
//
//  Created by Isaac Smead on 12/19/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var flashairHost: UITextField!
    @IBOutlet weak var flashairRoot: UITextField!
    @IBOutlet weak var cloudUser: UITextField!
    @IBOutlet weak var cloudPass: UITextField!
    @IBOutlet weak var cloudHost: UITextField!
    @IBOutlet weak var cloudTarget: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = Settings.shared
        flashairHost.text = settings[.flashairHost]
        flashairRoot.text = settings[.flashairRoot]
        cloudUser.text = settings[.nextcloudUser]
        cloudPass.text = settings[.nextcloudPassword]
        cloudHost.text = settings[.nextcloudHost]
        cloudTarget.text = settings[.nextcloudTarget]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onSaveButton(_ sender: UIBarButtonItem) {
        let settings = Settings.shared
        if let faHost = flashairHost.text {
            settings.update(field: .flashairHost, value: faHost)
        }
        if let faRoot = flashairRoot.text {
            settings.update(field: .flashairRoot,value: faRoot)
        }
        if let ncUser = cloudUser.text {
            settings.update(field: .nextcloudUser, value: ncUser)
        }
        if let ncPass = cloudPass.text {
            settings.update(field: .nextcloudPassword, value: ncPass)
        }
        if let ncHost = cloudHost.text {
            settings.update(field: .nextcloudHost, value: ncHost)
        }
        if let ncTarget = cloudTarget.text {
            settings.update(field: .nextcloudTarget, value: ncTarget )
        }
        settings.save()
        view.endEditing(false)
    }
}
