//
//  ViewController.swift
//  PhotoManagement
//
//  Created by Kazuma Hatada on 2019/08/05.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import UIKit
import Photos

class ListViewController: UITableViewController {
    
    //let TODO = ["牛乳を買う", "掃除をする", "アプリ開発の勉強をする"] // 追加②
    
    let manager = PHImageManager.default()

    var photoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getAllSortedPhotosInfo()

        // カメラロールへのアクセス許可を事前に取らないとDetailViewでPHAssetが取得できない（画像は取得できる）
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            print("status is \(newStatus)")
            if newStatus ==  PHAuthorizationStatus.authorized {
                /* do stuff here */
                print("success")
            }
        })
    }

    // 追加③ セルの個数を指定するデリゲートメソッド（必須）
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    // 追加④ セルに値を設定するデータソースメソッド（必須）
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "OneCell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = formatDateToStr(photoAssets[indexPath.row].creationDate)
        
        manager.requestImage(for: photoAssets[indexPath.row], targetSize: CGSize(width: 140, height: 140), contentMode: .aspectFit, options: nil) { (img, info) in
            // imageをセットする
            cell.imageView?.image = img
        }
        
        return cell
    }

    private func getAllSortedPhotosInfo() {
        photoAssets = []
        
        // ソート条件を指定
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.fetchLimit = 10
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assets.enumerateObjects { (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        }
        
        //print(photoAssets)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let oneData:PHAsset = photoAssets[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.detailPHAsset = oneData
        }
    }
}

