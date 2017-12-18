//
//  FolderCell.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/27/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit

class FolderCell: UICollectionViewCell {
    
    @IBOutlet weak var folderLabel: UILabel!
    
    
    func setLabel(fileName: String){
        folderLabel.text = fileName
    }
    
}
