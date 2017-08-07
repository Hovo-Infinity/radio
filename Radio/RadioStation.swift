//
//  RadioStation.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/25/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class RadioStationStream {
    var stream:String = "";
    var bitrate:Int = 32;
    var content_type:String = "";
    var status:Int =  0;
    var listeners:Int = 0;
}

class RadioStationCategory {
    var categoryId:Int = 0;
    var title:String = "";
    var description:String = "";
    var slug:String = "";
    var ancestry:(Any)? = nil;
}

class RadioStation: NSObject {
    var uid:Int = 0;
    var name:String = "";
    var desc:String = "";
    var country:String = "";
    var website:String = "";
    var imageUrl:String = "";
    var thumbUrl:String = "";
    var created_at:String = "";
    var updated_at:String = "";
    var slug:String = "";
    var twitter:String = "";
    var facebook:String = "";
    var total_listeners:Int = 0;
    var streams:Array = [RadioStationStream]();
    var categories:Array = [RadioStationCategory]();
}
