//
//  SearchViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/20/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVKit

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    private var songs = [SongItem]()
    static let reuseIdentifier = "com.swift.Music.search.cell"
    private var dataTask: URLSessionDataTask?
    private var currentText: String?
    private let player = AVPlayer()
    private var currentSong: SongItem?
    
    @IBAction func back() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AVPlayer.sharedPlayer = player
        collectionView.register(UINib(nibName: "SongItemCell", bundle: nil), forCellWithReuseIdentifier: SearchViewController.reuseIdentifier)
        dataTask = RequestController.search("") {[weak self] (songs, error) in
            if error == nil {
                self?.songs = songs!
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } else {
                
            }
        }
        searchBar.text = currentText
        registerForNotifications();
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(downloadSuccess(notificatin:)), name: NSNotification.Name(rawValue: kDownloadSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadFail(notificatin:)), name: NSNotification.Name(rawValue: kDownloadFail), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(notificatin:)), name: NSNotification.Name(rawValue: kDownloadInprogress), object: nil)
    }
    
    @objc
    func downloadSuccess(notificatin:Notification) {
        let userInfo = notificatin.userInfo
        let url = (userInfo!["url"] as! URL).absoluteString
        guard let index = songs.index(where: {
            if $0.downloadUrl != nil {
                return $0.downloadUrl! == url
            }
            return false
        }),
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SongItemCell else { return }
        cell.downloadProgressView.progress = 0.0
    }
    
    @objc
    func downloadFail(notificatin:Notification) {
        let userInfo = notificatin.userInfo
        let url = (userInfo!["url"] as! URL).absoluteString
        guard let index = songs.index(where: {
            if $0.downloadUrl != nil {
                return $0.downloadUrl! == url
            }
            return false
        }),
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SongItemCell else { return }
        cell.downloadProgressView.setProgress(0.0, animated: true)
    }
    
    @objc
    func downloadProgress(notificatin:Notification) {
        let userInfo = notificatin.userInfo
        let url = (userInfo!["url"] as! URL).absoluteString
        guard let index = songs.index(where: {
            if $0.downloadUrl != nil {
                return $0.downloadUrl! == url
            }
            return false
        }),
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SongItemCell else { return }
        let percent = userInfo?["percent"] as! Float
        cell.downloadProgressView.setProgress(percent, animated: true)
    }

}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewController.reuseIdentifier, for: indexPath) as! SongItemCell
        let song = songs[indexPath.item]
        cell.update(song: song)
        cell.playTapped = {[weak self] playButton in
            if song.listenUrl == nil {
                RequestController.getSongUrls(song: song) {songItem, error in
                    if error == nil {
                            let playing = self?.prepareToPlay(song: song)
                            DispatchQueue.main.async {
                                if playing == true {
                                    playButton.setImage(#imageLiteral(resourceName: "pause_circle"), for: .normal)
                                } else {
                                    playButton.setImage(#imageLiteral(resourceName: "play_circle"), for: .normal)
                                }
                            }
                        
                    }
                }
            } else {
                let playing = self?.prepareToPlay(song: song)
                if playing == true {
                    playButton.setImage(#imageLiteral(resourceName: "pause_circle"), for: .normal)
                } else {
                    playButton.setImage(#imageLiteral(resourceName: "play_circle"), for: .normal)
                }
            }
        }
        cell.saveTapped = {
            if song.downloadUrl == nil {
                RequestController.getSongUrls(song: song) {songItem, error in
                    if error == nil {
                        let downloadUrl = URL(string: song.downloadUrl!)!
                        Downloader.downloader().download(url: downloadUrl, saveTo: FileManager.songPath().appendingPathComponent(song.name + FileExtensions.mp3.rawValue))
                    } else {
                        print(error!.localizedDescription)
                    }
                }
            } else {
                let downloadUrl = URL(string: song.downloadUrl!)!
                Downloader.downloader().download(url: downloadUrl, saveTo: FileManager.songPath().appendingPathComponent(song.name + FileExtensions.mp3.rawValue))
            }
            
        }
        return cell
    }
    
    func prepareToPlay(song: SongItem) -> Bool {
//        metadataCollector = AVPlayerItemMetadataCollector()
//        metadataCollector.setDelegate(self, queue: DispatchQueue.main)
        if currentSong != nil {
            if currentSong! == song {
                if (self.player.timeControlStatus == AVPlayerTimeControlStatus.waitingToPlayAtSpecifiedRate ||
                    self.player.timeControlStatus == AVPlayerTimeControlStatus.paused) {
                    self.player.play()
                    return true
                } else {
                    self.player.pause()
                    return false
                }
            } else {
                let url = URL(string: song.listenUrl!)!
                let playerItem = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: playerItem)
                player.play()
                currentSong = song
                return true
            }
        } else {
            let url = URL(string: song.listenUrl!)!
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            currentSong = song
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width
        let h = CGFloat(50)
        return CGSize(width: w, height: h)
    }
       
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        dataTask?.cancel()
        dataTask = RequestController.search(query) {[weak self] (songs, error) in
            if error == nil {
                self?.songs = songs!
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } else {
                
            }
        }
        dataTask?.resume()
        currentText = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = currentText
    }
}
