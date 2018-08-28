//
//  FavoritesViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/27/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    public var urlRequest:NSURLRequest? = nil
    private var songName:String = ""
    private var musicURLs:Array<URL> = {
            do {
                return try FileManager.default.contentsOfDirectory(at: FileManager.songPath())
            } catch {
                return []
            }
    }()
    var player: AVPlayer!
    private var nowPlayingIndex: Int = NSNotFound
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlayer()
        let session = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try session.setCategory(AVAudioSessionCategoryPlayback,
                                        mode: AVAudioSessionModeMoviePlayback,
                                        options: [])
            } else {
                // Fallback on earlier versions
                try session.setMode(AVAudioSessionModeMoviePlayback)
                try session.setCategory(AVAudioSessionCategoryPlayback)
            }
            do {
                try session.setActive(true)
            } catch {
                print("Unable to activate audio session: \(error.localizedDescription)")
            }
        } catch let error as NSError {
            print ("Failed to set the audio session category and mode : \(String(describing: error.localizedFailureReason))")
        }
        self.navigationItem.title = NSLocalizedString("gen_favorites", comment: "")
        if self.urlRequest != nil {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(downloadSuccess(notificatin:)), name: NSNotification.Name(rawValue: kDownloadSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadFail(notificatin:)), name: NSNotification.Name(rawValue: kDownloadFail), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(notificatin:)), name: NSNotification.Name(rawValue: kDownloadInprogress), object: nil)
    }
    
    private func initPlayer() {
        let url = musicURLs.first!
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        AVPlayer.sharedPlayer = player
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicURLs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = self.musicURLs[indexPath.row]
        if FileManager.default.directoryExcist(atPath: url.path) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "directoryCell", for: indexPath)
            cell.textLabel?.text = url.lastPathComponent
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicTableViewCell
            cell.playButton.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
            cell.playButton.tag = indexPath.row
            cell.playButton.isPlaying = nowPlayingIndex == indexPath.item
            configCell(cell)
            return cell
        }
    }
    
    private func configCell(_ cell: MusicTableViewCell) {
        let url = musicURLs[cell.playButton.tag]
        let asset = AVAsset(url: url)
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            if metaDataItems.commonKey!.rawValue == "title" {
                let titleData = metaDataItems.value as! String
                cell.textLabel?.text = titleData
            }
            //getting the "Artist of the mp3 file"
            if metaDataItems.commonKey!.rawValue == "artist" {
                let artistData = metaDataItems.value as! String
                cell.detailTextLabel?.text = artistData
                print("artist ---> \(artistData)")
            }
        }
    }
    
    @objc
    private func play(_ sender: PlayButton) {
        if (nowPlayingIndex != sender.tag) {
            let reloadIndexes = [IndexPath(row: nowPlayingIndex, section: 0), IndexPath(row: sender.tag, section: 0)]
            nowPlayingIndex = sender.tag
            let url = musicURLs[nowPlayingIndex]
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: item)
            player.play()
            tableView.reloadRows(at: reloadIndexes, with: .automatic)
        } else {
            if (self.player.status == AVPlayerStatus.readyToPlay) {
                if #available(iOS 10.0, *) {
                    if (self.player.timeControlStatus == AVPlayerTimeControlStatus.waitingToPlayAtSpecifiedRate ||
                        self.player.timeControlStatus == AVPlayerTimeControlStatus.paused) {
                        self.player.play()
                        sender.isPlaying = true
                    } else {
                        self.player.pause()
                        sender.isPlaying = false
                    }
                } else {
                    // Fallback on earlier versions
                    if (self.player.rate == 0.0) {
                        self.player.play()
                        sender.isPlaying = true
                    } else {
                        player.pause()
                        sender.isPlaying = false
                    }
                }
            } else {
                let alert = UIAlertController(title:
                    self.player.error?.localizedDescription, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
                alert.addAction(ok)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.musicURLs[indexPath.row]
        if FileManager.default.directoryExcist(atPath: url.path) {
            let viewController = SimpleViewController(path: url.path)
            viewController.navigationItem.title = url.lastPathComponent
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let waveViewController:WaveViewController = WaveViewController(fileUrl: url)
            waveViewController.navigationItem.title = url.lastPathComponent
            self.navigationController?.pushViewController(waveViewController, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let groupAction = UITableViewRowAction(style: .default, title: NSLocalizedString("move_to", comment: "")) {[unowned tableView] (action, indexPath) in
            if FileManager.default.createSubdirectoryOfSongPath(maned: "Rap") {
                do {
                    let url = self.musicURLs[indexPath.row]
                    try FileManager.default.moveItem(at: url, to: FileManager.songPath().appendingPathComponent("Rap").appendingPathComponent((url.lastPathComponent)))
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        groupAction.backgroundColor = .gray
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { [unowned self](action, indexPath) in
            do {
                try FileManager.default.removeItem(at: self.musicURLs[indexPath.row]);
                self.musicURLs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
        }
        deleteAction.backgroundColor = .red
        return [groupAction, deleteAction]
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            do {
                try FileManager.default.removeItem(at: self.musicURLs[indexPath.row]);
                tableView .deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    

    @IBAction func save(_ sender: Any) {
        let alertController = UIAlertController(title: "Save", message: "Write Song Name", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { [unowned self](action) in
            self.songName = ((alertController.textFields?.first?.text!)?.appending(".mp3"))!
            Downloader.downloader().download(url: (self.urlRequest?.url!)!, saveTo: FileManager.songPath().appendingPathComponent(self.songName))
            self.saveButton.isEnabled = false
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func swipeHandler(_ sender:UISwipeGestureRecognizer?) {
        if (sender?.direction == .left) {
            tableView.setEditing(true, animated: true)
        } else if (sender?.direction == .right) {
            tableView.setEditing(false, animated: true)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if let _ = self.navigationController?.viewControllers.first?.isEqual(self) {
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        } else if self.navigationController == nil && self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc
    func downloadSuccess(notificatin:Notification) {
        progressView.progress = 0
        tableView.reloadData()
    }
    
    @objc
    func downloadFail(notificatin:Notification) {
        progressView.setProgress(0, animated: true)
    }
    
    @objc
    func downloadProgress(notificatin:Notification) {
        let info = notificatin.userInfo
        let percent = info?["percent"] as! Float
        progressView.setProgress(percent, animated: true)
    }
}
