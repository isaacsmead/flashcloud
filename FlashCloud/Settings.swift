//
//  Settings.swift
//  FlashCloud
//
//  Created by Isaac Smead on 12/19/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import Foundation

enum SettingsFields: String {
    case flashairHost = "flashairHost"
    case flashairRoot = "flashairRoot"
    case nextcloudHost = "nextcloudHost"
    case nextcloudPassword =  "nextcloudPassword"
    case nextcloudUser = "nextcloudUser"
    case nextcloudRoot = "nextcloudRoot"
    case nextcloudTarget = "nextcloudTarget"
    
    static let allFields = [
        flashairHost,
        flashairRoot,
        nextcloudHost,
        nextcloudPassword,
        nextcloudUser,
        nextcloudRoot,
        nextcloudTarget]
}

class Settings {
    
    static let shared = Settings()
    
    // for now not worrying about saving things other than strings and assuming no optionals
    // app exits if plist doesn't exist, in future first time start up might not have,
    // should prompt user to enter settings and create if doesn't exist
    
    var settings : Dictionary<String, Any>
    let saveUrl: URL
    let defautUrl = Bundle.main.url(forResource: "Settings", withExtension: "plist")!
    private init(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        saveUrl = paths[0].appendingPathComponent("Settings.plist")
        do {
            let data:Data
            if let saved = try? Data(contentsOf: saveUrl){
                data = saved
                NSLog("using saved settings!")
            }
            else {
                data = try Data(contentsOf: defautUrl)
            }
            settings =  try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
            
        }
        catch {
            NSLog("Unable to open Settings plist")
            exit(1)
        }
    }
    
    subscript(field: SettingsFields) -> String{
        get {
            return settings[field.rawValue] as! String
        }
    }
    
    func update(field: SettingsFields, value: String){
        settings[field.rawValue] = value
        
    }
    
    func save() -> Bool {
        do {
            let result:Data
            try result = PropertyListSerialization.data(fromPropertyList: settings, format: .xml, options: 0)
            try result.write(to: saveUrl)
        }
        catch{
            NSLog("Error searializing settings")
            return false
        }
        return true
    }
}
