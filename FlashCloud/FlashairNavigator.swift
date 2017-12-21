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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    
    var thumbs = ThumbnailCollection()
    var dirs: [String] = []
    var path: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.collectionViewLayout = CustomLayout()
        collectionView?.allowsMultipleSelection = true

        if let savedPath = UserDefaults.standard.string(forKey: "savedPath"){
            path = savedPath.components(separatedBy: "/")
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                     selector: #selector(handleFlashairError),
                     name: .flashAirError,
                     object: nil)
        
        nc.addObserver(self,
                       selector: #selector(handleNextcloudError),
                       name: .nextCloudError,
                       object: nil)
        
        updateTitle()
        updateFileList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***********************************  OUTLETS *******************************************************
    
    @IBAction func upOneLevel(_ sender: UIBarButtonItem) {
        deselectAll()
        if(path.count > 0){
            path.removeLast()
        }
        updateFileList()
    }

    @IBAction func deleteSelected(_ sender: Any) {
        for fileName in thumbs.getSelected(){
            FlashairConnection.deleteFile(fileName: fileName,
                                    path: path.joined(separator: "/"),callback: onFileDeleted)
        }
    }
    
    @IBAction func uploadSelected(_ sender: UIBarButtonItem) {
        for fileName in thumbs.getSelected() {
            FlashairConnection.getImageData(fileName: fileName, path: path.joined(separator: "/"), callback: onImageDownloaded)
        }
    }
    
    //***********************************  CALLBACKS  *******************************************************

    func onImageDownloaded(_ fileName: String,_  data: Data){
        CloudConnection.shared.uploadImageData(data: data, fileName: fileName, callBack: onFileUploaded)
    }
    
    func onFlashairFileList(_ dirNames:[String], _ fileNames:[String]){
        dirs = dirNames
        collectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition(rawValue: 0))
        thumbs = ThumbnailCollection(imageFiles: fileNames)
        for fileName in thumbs.getFileNames(){
            FlashairConnection.getThumbnail(fileName: fileName, path: path.joined(separator: "/"), callback: self.onThumbnail)
        }
        updateTitle()
        collectionView.reloadData()
    }
    
    func onThumbnail(_ fileName:String, _ thumb: UIImage){
        if let row = thumbs.addThumbnail(fileName: fileName, image: thumb) {
            let ip = IndexPath(row: row, section: 1)
            collectionView.reloadItems(at: [ip])
            if thumbs.isSelected(fileName: fileName){
                collectionView.cellForItem(at: ip)?.isSelected = true
            }
        }
        else {
            NSLog("Error, unexpected thumbnail \(fileName)")
        }
    }
    
    func onFileUploaded(_ fileName:String){
        FlashairConnection.deleteFile(fileName: fileName,
                                      path: path.joined(separator: "/"),callback: onFileDeleted)
    }
    
    func onFileDeleted(_ fileName:String){
        thumbs.remove(fileName: fileName)
        deselectAll()
        collectionView.reloadData()
    }
    
    //***********************************  DELEGATES  *******************************************************

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
            deselectAll()
            updateFileList()
        }
        else{
            thumbs.select(index: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath){
        if(indexPath.section == 1){
            thumbs.deSelect(index: indexPath.row)
        }
    }
    
    //***********************************  HELPERS  *******************************************************

    @objc private func handleFlashairError(_ notification: NSNotification){
        let message = notification.userInfo?["message"] as? String ?? "Unknown Error"
        showAlert(title: "Flashair Error", message: message)
    }
    
    @objc private func handleNextcloudError(_ notification: NSNotification){
        let message = notification.userInfo?["message"] as? String ?? "Unknown Error"
        showAlert(title: "NextCloud Error", message: message)
    }
    
    private func showAlert(title: String, message: String){
        let alertController =
            UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController
            .addAction(UIAlertAction(title: "OK",  style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateFileList(){
        FlashairConnection.getFileList(path: path.joined(separator: "/"), callback: self.onFlashairFileList)
    }
    
    private func deselectAll(){
        for index in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: index, animated: false)
        }
    }
    
    private func updateTitle(){
        if let currentDir = path.last {
            navBar.title = currentDir
        }
        else{
            navBar.title = Settings.shared[.flashairRoot]
        }
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
