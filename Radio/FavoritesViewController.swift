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
    private var musicURLs:Array<URL> {
        get {
            do {
                return try FileManager.default.contentsOfDirectory(at: FileManager.songPath())
            } catch {
                return []
            }
        }
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let cell:MusicTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicTableViewCell
            cell.setURL(_url: self.musicURLs[indexPath.row]);
            return cell
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
            let cell:MusicTableViewCell = tableView.cellForRow(at: indexPath) as! MusicTableViewCell;
            if FileManager.default.createSubdirectoryOfSongPath(maned: "Rap") {
                do {
                    try FileManager.default.moveItem(at: cell.url!, to: FileManager.songPath().appendingPathComponent("Rap").appendingPathComponent((cell.url?.lastPathComponent)!))
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
                tableView .deleteRows(at: [indexPath], with: .fade)
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
