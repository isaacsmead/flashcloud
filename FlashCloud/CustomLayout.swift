//
//  CustomLayout.swift
//  FlashCloud
//
//  Created by Isaac Smead on 12/18/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//  basic ideas borrowed from here  http://zappdesigntemplates.com/create-3-column-grid-view-with-uicollectionview/

import UIKit

class CustomLayout: UICollectionViewFlowLayout {
    let spacing: CGFloat = 1
    let numberOfColumns : CGFloat = 3
    
    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    func setupLayout() {
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
        scrollDirection = .vertical
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - 1) * spacing) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    

}
