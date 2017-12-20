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
    var thumbs = Dictionary<String, UIImage>()
    let defaultImage = UIImage(named: "defaultImage2.png")
    var selected = Set<String>()
    
// DO we need a default init?
    init(){
        fileNames = []
    }
    
    init(imageFiles: [String]){
        fileNames = imageFiles
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
    
    func select(index: Int){
        if index < fileNames.count{
            selected.insert(fileNames[index])
        }
    }
    
    func deSelect(index: Int){
        if index < fileNames.count {
            selected.remove(fileNames[index])
        }
    }
    
    func remove(fileName: String){
        if let idx = fileNames.index(of: fileName){
            thumbs.removeValue(forKey: fileName)
            fileNames.remove(at: idx)
            selected.remove(fileName)
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
    
    func getSelected() -> [String] {
        return Array(selected)
    }
}
