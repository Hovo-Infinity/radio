//
//  RequestController.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/25/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class RequestController: NSObject {
    private static let APIBaseURL:String = "http://api.dirble.com/v2/";
    private static let token:String = "b3c8c7304d26a50f5dca9adf65";
    var _URL:URL? = nil;
    var comlition:((_ response:Any)->Void)? = nil;
    var failure:((_ error:Error)->Void)? = nil;
    
    class func getStationInYourLocation() -> URL {
        let manager = Locale.current.regionCode
        return URL(string: "stroig")!;
    }
    
    class func getAllStations() -> URL {
        let url:String = String(format: "%@stations?%@", APIBaseURL, token);
        return URL(string: url)!;
    }
    
    func doGetRequest() -> Void {
        let UrlRequest:NSMutableURLRequest = NSMutableURLRequest(url: _URL!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3);
        UrlRequest.httpMethod = "GET";
        let session:URLSession = URLSession(configuration: URLSessionConfiguration.default);
        let dataTask = session.dataTask(with: UrlRequest as URLRequest) { [unowned self](data, UrlResponse, error) in
            if error == nil {
                let response = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves);
                if let handler = self.comlition {
                    handler(response!);
                }
            } else {
                
            }
        };
        dataTask.resume();
    }
    
}
