//
//  ViewController.swift
//  MusicEffect
//
//  Created by Kazuma Hatada on 2019/07/29.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var vImageView: UIImageView!
    @IBOutlet weak var lArtist: UILabel!
    @IBOutlet weak var lSong: UILabel!

    @IBAction func bChoose(_ sender: UIButton) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }

    @IBAction func bStart(_ sender: UIButton) {
        player.play()
//        if url == nil {
//            print ("nil dayo")
//            return
//        }
//        startEngine(playFileAt: url!)
    }
    @IBAction func bPause(_ sender: UIButton) {
        player.pause()
    }
    @IBAction func bStop(_ sender: UIButton) {
        player.stop()
    }
    
    var player = MPMusicPlayerController.applicationMusicPlayer

    var engine = AVAudioEngine()
    
    var url:URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 再生中のItemが変わった時に通知を受け取る
        let notificationCenter = NotificationCenter()
        notificationCenter.addObserver(self, selector: #selector(type(of: self).nowPlayingItemChanged(notification:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        // 通知の有効化
        player.beginGeneratingPlaybackNotifications()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // プレイヤーを止める
        player.stop()
        
        // 選択した曲情報がmediaItemCollectionに入っているので、これをplayerにセット。
        player.setQueue(with: mediaItemCollection)
        
        // 選択した曲から最初の曲の情報を表示
        if let mediaItem = mediaItemCollection.items.first {
            url = mediaItem.assetURL
            updateSongInformationUI(mediaItem)
        }
        
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    /// 選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    /// 曲情報を表示する
    func updateSongInformationUI(_ mediaItem: MPMediaItem) {
        
        // 曲情報表示
        // (a ?? b は、a != nil ? a! : b を示す演算子です)
        // (aがnilの場合にはbとなります)
        lArtist.text = mediaItem.artist ?? "不明なアーティスト"
        lSong.text = mediaItem.title ?? "不明な曲"
        
        // アートワーク表示
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: vImageView.bounds.size)
            vImageView.image = image
        } else {
            // アートワークがないとき
            // (今回は灰色表示としました)
            vImageView.image = nil
            vImageView.backgroundColor = UIColor.gray
        }
        
    }
    
    /// 再生中の曲が変更になったときに呼ばれる
    @objc func nowPlayingItemChanged(notification: NSNotification) {
        
        if let mediaItem = player.nowPlayingItem {
            updateSongInformationUI(mediaItem)
        }
        
    }
    
    deinit {
        // 再生中アイテム変更に対する監視をはずす
        let notificationCenter = NotificationCenter()
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        // ミュージックプレーヤー通知の無効化
        player.endGeneratingPlaybackNotifications()
    }

    func startEngine(playFileAt: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            
            let avAudioFile = try AVAudioFile(forReading: playFileAt)
            let player = AVAudioPlayerNode()
            
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: avAudioFile.processingFormat)
            
            try engine.start()
            player.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
            player.play()
        } catch {
            assertionFailure(String(describing: error))
        }
    }
}
/*
1. Add the NSAppleMusicUsageDescription key to your Info.plist file, and its corresponding value
2. Setup the AVAudioSession and the `AVAudioEngine
3. Find the URL of the media item you want to play
    (you can use MPMediaPickerController like in the example below or you can make your own MPMediaQuery)
4. Create an AVAudioFile from that URL
5. Create an AVAudioPlayerNode set to play that AVAudioFile
6. Connect the player node to the engine's output node

import UIKit
import AVFoundation
import MediaPlayer
class ViewController: UIViewController {
 
    let engine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.showsCloudItems = false // you won't be able to fetch the URL for media items stored in the cloud
        mediaPicker.delegate = self
        mediaPicker.prompt = "Pick a track"
        present(mediaPicker, animated: true, completion: nil)
    }
 
    func startEngine(playFileAt: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)

            let avAudioFile = try AVAudioFile(forReading: playFileAt)
            let player = AVAudioPlayerNode()
 
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: avAudioFile.processingFormat)
 
            try engine.start()
            player.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
            player.play()
        } catch {
            assertionFailure(String(describing: error))
        }
    }
}
extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let item = mediaItemCollection.items.first else {
            print("no item")
            return
        }
        print("picking \(item.title!)")
        guard let url = item.assetURL else {
            return print("no url")
        }
        
        dismiss(animated: true) { [weak self] in
            self?.startEngine(playFileAt: url)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
*/
