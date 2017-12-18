//
//  ThumbnailCollection.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/27/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailCollection {
    
    var fileNames: [String]
    var thumbs: Dictionary<String, UIImage>
    let defaultImage = UIImage(named: "folder.png")
    
// DO we need a default init?
    init(){
        fileNames = []
        thumbs = Dictionary<String, UIImage>()
    }
    
    init(imageFiles: [String]){
        fileNames = imageFiles
        thumbs = Dictionary<String, UIImage>()
    }
    
    func addThumbnail(fileName: String, image: UIImage) -> Bool{
        if fileNames.contains(fileName){
            thumbs[fileName] = image
            return true
        }
        return false
    }
    
    subscript (index: Int) -> UIImage {
        get {
            if index < fileNames.count, let img = thumbs[fileNames[index]]{
                return img
            }
            return defaultImage!
        }
    }
    
    func clear(){
        fileNames.removeAll()
        thumbs.removeAll()
    }
    
    func count() -> Int {
        return fileNames.count
    }
    
    func getFileNames() -> [String]{
        return fileNames
    }
}
