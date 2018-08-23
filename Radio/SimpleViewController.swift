//
//  SimpleViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 2/15/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation

class SimpleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    private var path:String!
    private var songName:String = ""
    private var musicURLs:Array<URL> {
        get {
            do {
                return try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: path))
            } catch {
                return []
            }
        }
    }
    
    init(path aPath:String!) {
        super.init(nibName: nil, bundle: nil)
        path = aPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableView: UITableView!
    
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
        tableView = UITableView(frame: self.view.bounds)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "directoryCell")
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        self.edgesForExtendedLayout = []
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
            return cell
        }
    }
    
    private func swipeGestureOnCell(_ cell:UITableViewCell) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        leftSwipeGesture.direction = .left
        cell.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        rightSwipeGesture.direction = .right
        cell.addGestureRecognizer(rightSwipeGesture)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.musicURLs[indexPath.row]
        if FileManager.default.directoryExcist(atPath: url.path) {
            let viewController = SimpleViewController(path: url.path)
            viewController.navigationItem.title = url.lastPathComponent
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let groupAction = UITableViewRowAction(style: .default, title: NSLocalizedString("move_to", comment: "")) { (action, indexPath) in
            let cell:MusicTableViewCell = tableView.cellForRow(at: indexPath) as! MusicTableViewCell
            if FileManager.default.createSubdirectoryOfSongPath(maned: "Rap") {
                do {
                    let url = self.musicURLs[indexPath.row]
                    try FileManager.default.moveItem(at: url, to: FileManager.songPath().appendingPathComponent("Rap").appendingPathComponent((url.lastPathComponent)))
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
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
    
    @objc func swipeHandler(_ sender:UISwipeGestureRecognizer?) {
        if (sender?.direction == .left) {
            tableView.setEditing(true, animated: true)
        } else if (sender?.direction == .right) {
            tableView.setEditing(false, animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
