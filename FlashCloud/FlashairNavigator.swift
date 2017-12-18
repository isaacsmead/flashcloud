//
//  ThumbnailController.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/27/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit
import Foundation

class FlashairNavigator: UICollectionViewController {

    var thumbs = ThumbnailCollection()
    var dirs: [String] = []
    var path: [String] = []
    let flashAirConn = FlashairConnection.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(FolderCell.self, forCellWithReuseIdentifier: "FolderCell")
        self.collectionView!.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")

        if let savedPath = UserDefaults.standard.string(forKey: "savedPath"){
            path = savedPath.components(separatedBy: "/")
        }
        
        flashAirConn.getFileList(path: path.joined(separator: "/"), callback: self.onFlashairFileList)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0){
            return dirs.count
        }
        return thumbs.count()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0){
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath)
            (cell as! FolderCell).setLabel(fileName: dirs[indexPath.row])
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath)
            (cell as! ThumbnailCell).setImage(image: thumbs[indexPath.row])
            return cell

        }
        
    }
    
    func onFlashairFileList(_ dirNames:[String], _ fileNames:[String]){
        dirs = dirNames
        thumbs = ThumbnailCollection(imageFiles: fileNames)
        for fileName in thumbs.getFileNames(){
            flashAirConn.getThumbnail(fileName: fileName, path: path.joined(separator: "/"), callback: self.onThumbnail)
        }
        
        self.collectionView?.reloadData()
    }
    
    
    func onThumbnail(_ fileName:String, _ thumb: UIImage){
        if !thumbs.addThumbnail(fileName: fileName, image: thumb) {
            NSLog("Error, unexpected thumbnail \(fileName)")
        }
        
        /// TODO redraw
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
