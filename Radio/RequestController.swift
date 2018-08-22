//
//  RequestController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/25/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import SwiftSoup

class RequestController: NSObject {
    private static let baseUrl:String = "http://mp3party.net/";
    var comlition:((_ response:Any)->Void)? = nil;
    var failure:((_ error:Error)->Void)? = nil;
    private static let search = "search"
    
    class func search(_ q: String, completion: @escaping ([SongItem]?, Error?)->Void) -> URLSessionDataTask {
        var urlComponents = URLComponents(string: baseUrl + search)
        let queryItems = [URLQueryItem(name: "q", value: q)]
        urlComponents?.queryItems = queryItems
        let url = urlComponents?.url!
        let UrlRequest:NSMutableURLRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3);
        UrlRequest.httpMethod = "GET";
        let session:URLSession = URLSession(configuration: URLSessionConfiguration.default);
        let dataTask = session.dataTask(with: UrlRequest as URLRequest) { (data, UrlResponse, error) in
            if error == nil {
                var songs = [SongItem]()
                let htmlString = String(data: data!, encoding: .utf8)
                let document = try? SwiftSoup.parse(htmlString!)
                let elements = try? document?.select(".song-item")
                for element in elements!! {
                    let childElem = element.child(0)
                    let title = try? childElem.text()
                    let id = try? childElem.attr("href")
                    let songItem = SongItem(id: id!, name: title!)
                    songs.append(songItem)
                }
                completion(songs, nil)
            } else {
                completion(nil, error)
            }
        }
        defer {
            dataTask.resume();
        }
        return dataTask
    }
    
    class func getSongUrls(song: SongItem, completion: @escaping(SongItem, Error?)->Void) {
        var urlComponents = URLComponents(string: baseUrl + song.id)
        let url = urlComponents?.url!
        let UrlRequest:NSMutableURLRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3);
        UrlRequest.httpMethod = "GET";
        let session:URLSession = URLSession(configuration: URLSessionConfiguration.default);
        var tempSong = song
        let dataTask = session.dataTask(with: UrlRequest as URLRequest) { (data, UrlResponse, error) in
            if error == nil {
                let htmlString = String(data: data!, encoding: .utf8)
                let document = try? SwiftSoup.parse(htmlString!)
                var elements = try? document?.select(".jp-play")
                let playElem = elements!!.get(0)
                tempSong.listenUrl = try? playElem.attr("href")
                elements = try? document?.select(".download")
                tempSong.downloadUrl = try! elements!!.first()?.child(0).attr("href")
                completion(tempSong, nil)
            } else {
                completion(tempSong, error)
            }
        }
        defer {
            dataTask.resume();
        }
    }
}
