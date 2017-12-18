//
//  ThumbnailCell.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/27/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    func setImage(image: UIImage){
        self.image.image = image
    }
}
