//
//  DetailViewController.swift
//  PhotoManagement
//
//  Created by Kazuma Hatada on 2019/08/05.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import UIKit
import Photos
import Foundation
import ImageIO
import MapKit

class DetailViewController : UIViewController {
    
    @IBOutlet weak var iPhotoView: UIImageView!
    @IBOutlet weak var lCreateDate: UILabel!
    @IBOutlet weak var lLocation: UILabel!
    @IBOutlet weak var lWidthHeight: UILabel!
    @IBOutlet weak var mMapView: MKMapView!
    
    var detailPHAsset:PHAsset!
    
    let manager = PHImageManager.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//rensyuu()
        // カメラロールへのアクセス許可を事前に取らないとPHAssetが取得できない（画像は取得できる）
//        PHPhotoLibrary.requestAuthorization({
//            (newStatus) in
//            print("status is \(newStatus)")
//            if newStatus ==  PHAuthorizationStatus.authorized {
//                /* do stuff here */
//                print("success")
//            }
//        })
        
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: detailPHAsset, targetSize: CGSize(width: detailPHAsset.pixelWidth/4, height: detailPHAsset.pixelHeight/4), contentMode: .aspectFit, options: option) { (img, info) in
            self.iPhotoView.image = img
            //debugPrint(info!)
        }
        
        lCreateDate.text = formatDateToStr(detailPHAsset.creationDate)
        lLocation.text = detailPHAsset.location?.description ?? "Location unknown"
        lWidthHeight.text = "\(detailPHAsset.pixelWidth) x \(detailPHAsset.pixelHeight)"
        
        //let filename = self.detailPHAsset.value(forKey: "filename")
        //if let url = getNSURL(detailPHAsset) {
        //guard let url = getURL(detailPHAsset) else {
        detailPHAsset.getURL() { url in
        
            if url != nil {
                
                //let nsUrl:NSURL = NSURL(fileURLWithPath: url!.absoluteString) // 1.
                
                guard let urlAbsStr = url?.absoluteString else {
                    print("absoluteString だめ")
                    return
                }
                
                guard let nsUrl = NSURL(string: urlAbsStr) else { // 1.
                    print("NSURL だめ")
                    return
                }

                guard let imageSource = CGImageSourceCreateWithURL(nsUrl, nil) else { // 2.
                    print("imageSource だめ")
                    return
                }

                guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as! Dictionary<String, AnyObject>? else { // 3.
                    print("imageProperties だめ")
                    return
                }

                print(imageProperties)
                
                guard let gpsValue = imageProperties["{GPS}"] else { // 4.
                    print("gpsValue だめ")
                    return
                }
                
                let latValue = gpsValue["Latitude"] as? Double ?? 0
                let lonValue = gpsValue["Longitude"] as? Double ?? 0
                print("---- \(latValue) \(lonValue) ----")
                // 緯度・経度を設定
                let location:CLLocationCoordinate2D
                    //= CLLocationCoordinate2DMake(35.68154,139.752498)
                    = CLLocationCoordinate2DMake(latValue, lonValue)
                
                self.mMapView.setCenter(location, animated:true)
                
                // 縮尺を設定
                //var region:MKCoordinateRegion = mMapView.region
                //region.center = location
                //region.span.latitudeDelta = 0.02
                //region.span.longitudeDelta = 0.02
                //mMapView.setRegion(region, animated:true)
                
                // MKPointAnnotationインスタンスを取得し、ピンを生成
                let pin = MKPointAnnotation()
                pin.coordinate = location
                self.mMapView.addAnnotation(pin)
                
                // 検索地点の緯度経度を中心に半径500mの範囲を表示
                self.mMapView.region = MKCoordinateRegion(center: location, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                
                let locationForGeo = CLLocation(latitude: latValue, longitude: lonValue)
                CLGeocoder().reverseGeocodeLocation(locationForGeo) { placemarks, error in
                    guard let placemark = placemarks?.first, error == nil else { return }
                    // あとは煮るなり焼くなり
                    let kuni = placemark.country ?? "Unknown"
                    let ken = placemark.administrativeArea ?? "Unknown"
                    let ku = placemark.locality ?? ""
                    let tyou = placemark.thoroughfare ?? ""
                    let banchi = placemark.subThoroughfare ?? ""
                    
                    let juusyo = kuni + ", " + ken  + ", " + ku + ", " + tyou + ", " + banchi
                    
                    print(juusyo)
                }
                
            } else {
                print("getURL だめ")
            }
        }
    }

/*
    func getURL(ofPhotoWith mPhasset: PHAsset) -> URL{
        
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .original
        var urlStr2 = URL(string:"")
        
        let semaphore = DispatchSemaphore(value: 0)
        PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
            
            if let tokenStr = info?["PHImageFileSandboxExtensionTokenKey"] as? String {
                let tokenKeys = tokenStr.components(separatedBy: ";")
                let urlStr = tokenKeys.filter { $0.contains("/private/var/mobile/Media") }.first
                urlStr2 = URL(string:urlStr!)
                if let urlStr = urlStr {
                    if let url = URL(string: urlStr) {
                        print(url.lastPathComponent)
                        print(url.pathExtension)
                    }
                }
            }
            defer {semaphore.signal() }
        })
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return urlStr2!
        
    }
*/
    
    func getURL (_ asset: PHAsset) -> URL? {
        
        var retURL:URL?
        
        switch asset.mediaType {
        case .image:
            
            manager.requestImage(
                for: asset,
                targetSize: CGSize(width: 1, height: 1),
                contentMode: .aspectFit,
                options: nil) { (image, info) in
print(image)
print("------------------------------------------------------------")
print(info)
print("------------------------------------------------------------")

                    if let url = info?["PHImageFileURLKey"] as? URL {
                        retURL = url
                    } else {
                        print("getNSURL PHImageFileURLKey だめ")
                    }
                }
            
        case .video:
            
            let option = PHVideoRequestOptions()
            option.deliveryMode = .highQualityFormat
            
            manager.requestAVAsset(
                forVideo: asset,
                options: option,
                resultHandler: { (avAsset, audioMix, info) in
                    
                    if let tokenStr = info?["PHImageFileSandboxExtensionTokenKey"] as? String {
                        
                        let tokenKeys = tokenStr.components(separatedBy: ";")
                        let urlStr = tokenKeys.filter { $0.contains("/private/var/mobile/Media") }.first
                        
                        if let urlStr = urlStr {
                            if let url = URL(string: urlStr) {
                                retURL = url
                            }
                        }
                    }
            })
            
        default: break
        }
        
        return retURL
    }

    func rensyuu() {
//        let filepath = NSHomeDirectory() + "/flower_high.jpg"
//        let filepath = "/Users/kazumahatada/Desktop/flower_high.jpg"
//        let url: NSURL = NSURL(fileURLWithPath: filepath)
        if let url = NSURL(string: "http://www.ksky.ne.jp/~yamama/jpggpsmap/sample/MitakaEkimae.JPG") {
        
            if let imageSource = CGImageSourceCreateWithURL(url, nil) {
                
                if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) {
                    
                    if let dict = imageProperties as? [String: Any] {
                        print(dict)
                    }
                    
                } else {
                    print("imageProperties is nil")
                }
                
            } else {
                print("imageSource is nil")
            }

        } else {
            print("URL is nil")
        }
    }

}
