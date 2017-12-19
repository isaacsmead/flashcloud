//
//  ThumbnailController.swift
//  FlashCloud
//
//  Created by Isaac Smead on 11/27/17.
//  Copyright © 2017 Isaac Smead. All rights reserved.
//

import UIKit
//import Foundation

class FlashairNavigator: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var thumbs = ThumbnailCollection()
    var dirs: [String] = []
    var path: [String] = []
    let flashAirConn = FlashairConnection.sharedInstance
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.collectionViewLayout = CustomLayout()
        collectionView?.allowsMultipleSelection = true
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        if let savedPath = UserDefaults.standard.string(forKey: "savedPath"){
            path = savedPath.components(separatedBy: "/")
        }
        
        updateFileList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upOneLevel(_ sender: UIBarButtonItem) {
        if(path.count > 0){
            path.removeLast()
        }
        updateFileList()
    }

    @IBAction func deleteSelected(_ sender: Any) {
        for fileName in thumbs.getSelected(){
            flashAirConn.deleteFile(fileName: fileName,
                                    path: path.joined(separator: "/"),callback: onFileDeleted)
        }
    }
    
    @IBAction func uploadSelected(_ sender: UIBarButtonItem) {
    }
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0){
            return dirs.count
        }
        return thumbs.count()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            path.append(dirs[indexPath.row])
            updateFileList()
        }
        else{
            //addToList.append(objectsArray[indexPath.row])
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 2.0
            cell?.layer.borderColor = UIColor.blue.cgColor
            thumbs.select(index: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath){
        if(indexPath.section == 1){
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
            thumbs.deSelect(index: indexPath.row)
        }
    }
    
    func onFlashairFileList(_ dirNames:[String], _ fileNames:[String]){
        dirs = dirNames
        collectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition(rawValue: 0))
        thumbs = ThumbnailCollection(imageFiles: fileNames)
        for fileName in thumbs.getFileNames(){
            flashAirConn.getThumbnail(fileName: fileName, path: path.joined(separator: "/"), callback: self.onThumbnail)
        }
        
        collectionView.reloadData()
    }
    
    func onThumbnail(_ fileName:String, _ thumb: UIImage){
        if !thumbs.addThumbnail(fileName: fileName, image: thumb) {
            NSLog("Error, unexpected thumbnail \(fileName)")
        }
        collectionView.reloadData()
    }
    
    func onFileDeleted(_ fileName:String){
        thumbs.remove(fileName: fileName)
        collectionView.reloadData()
    }

    private func updateFileList(){
        flashAirConn.getFileList(path: path.joined(separator: "/"), callback: self.onFlashairFileList)
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
