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
    
    var keys: [String]
    var thumbs: Dictionary<String, UIImage>
    let defaultImage: UIImage = #imageLiteral(resourceName: "defaultImage.png")
    init(imageFiles: [String]){
        keys = imageFiles
        thumbs = Dictionary<String, UIImage>()
    }
    
    func addImage(fileName: String, image: UIImage){
        thumbs[fileName] = image
    }
    
    subscript (index: Int) -> UIImage {
        get {
            if index < keys.count, let img = thumbs[keys[index]]{
                return img
            }
            return defaultImage
        }
    }
    
    func clear(){
        keys.removeAll()
        thumbs.removeAll()
    }
    
    func count() -> Int {
        return keys.count
    }
}
