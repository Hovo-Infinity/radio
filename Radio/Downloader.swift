//
//  Downloader.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/8/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

let kDownloadStart:String = "com.radio.downloader.download.started";
let kDownloadSuccess:String = "com.radio.downloader.download.success";
let kDownloadFail:String = "com.radio.downloader.download.fail";
let kDownloadInprogress:String = "com.radio.downloader.download.inprogress";

class Downloader: NSObject, URLSessionDownloadDelegate {
    private static let _downloader = Downloader();
    private var savePath:URL? = nil;
    private var dataTask:URLSessionDownloadTask? = nil;
    private var session:URLSession? = nil;
    private var url:URL? = nil;
    
    class func downloader() -> Downloader {
        return _downloader;
    }
    
    public func download(url:URL, saveTo path:URL) {
        self.url = url;
        savePath = path;
        let urlRequest = URLRequest(url: url);
        let dataTask = session?.downloadTask(with: urlRequest);
        dataTask?.resume();
    }
    
    private override init() {
        super.init();
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main);
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: savePath!);
            let info:[String : Any] = ["url":url as Any, "path":savePath as Any];
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDownloadSuccess), object: self, userInfo: info);
        } catch {
            let info:[String : Any] = ["url":url as Any, "path":savePath as Any, "error":error as Any];
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDownloadFail), object: self, userInfo: info);
            print(error.localizedDescription);
        }
        
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        let info:[String : Any] = ["url":url as Any, "path":savePath as Any, "error":error as Any];
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDownloadFail), object: self, userInfo: info);
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percent:Float = Float(bytesWritten) / Float(totalBytesExpectedToWrite);
        let info:[String : Any] = ["url":url as Any, "path":savePath as Any, "percent":percent];
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDownloadInprogress), object: self, userInfo: info);
    }
}
