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

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate {
    public var urlRequest:NSURLRequest? = nil;
    private var songName:String = "";
    private var dataTask:URLSessionDownloadTask? = nil;
    private var musicURLs:Array<URL> {
        get {
            do {
                return try FileManager.default.contentsOfDirectory(at: FileManager.songPath());
            } catch {
                return [];
            }
        }
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("gen_favorites", comment: "");
        if self.urlRequest != nil {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main);
            self.dataTask = session.downloadTask(with: self.urlRequest! as URLRequest!);
            self.saveButton.isEnabled = true;
        } else {
            self.saveButton.isEnabled = false;
        }
        // Do any additional setup after loading the view.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicURLs.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MusicTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicTableViewCell;
        cell.setURL(url: self.musicURLs[indexPath.row]);
        return cell;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !PlayerPopUp.sharedPopUp.isShow {
            PlayerPopUp.sharedPopUp.show();
        }
    }

    @IBAction func save(_ sender: Any) {
        let alertController = UIAlertController(title: "Save", message: "Write Song Name", preferredStyle: UIAlertControllerStyle.alert);
        alertController.addTextField { (textField) in
            textField.placeholder = "Name";
        }
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            self.songName = ((alertController.textFields?.first?.text!)?.appending(".mp3"))!;
            self.dataTask?.resume();
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil);
        alertController.addAction(ok);
        alertController.addAction(cancel);
        self.present(alertController, animated: true, completion: nil);
    }
    
    @IBAction func Back(_ sender: Any) {
        if let _ = self.navigationController?.viewControllers.first?.isEqual(self) {
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil);
            }
        } else if self.navigationController == nil && self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil);
        } else {
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: FileManager.songPath().appendingPathComponent(self.songName));
            self.tableView.reloadData();
        } catch {
            print(error.localizedDescription);
        }

    }
}
