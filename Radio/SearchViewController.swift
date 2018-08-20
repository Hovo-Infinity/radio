//
//  SearchViewController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/20/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var songs = [SongItem]()
    static let reuseIdentifier = "com.swift.Music.search.cell"
    private var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width
        let h = CGFloat(30)
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
    }
}
