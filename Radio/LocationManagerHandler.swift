//
//  LocationManagerHandler.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/1/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManagerHandler: NSObject, CLLocationManagerDelegate {
    let manager:CLLocationManager;
    let geocoder:CLGeocoder;
    var countryCode:String;
    private override init() {
        manager = CLLocationManager();
        geocoder = CLGeocoder();
        countryCode = Locale.current.regionCode!;
        super.init();
        manager.requestWhenInUseAuthorization();
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self;
            manager.startMonitoringSignificantLocationChanges();
            manager.startUpdatingLocation();
        }
    }
    private static let _sharedManager = LocationManagerHandler();
    class func sharedManager() -> LocationManagerHandler {
        return _sharedManager;
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            self.countryCode = Locale.current.regionCode!;
        };
        let alert = UIAlertController(title: "", message: "Can Not Take Location, region will be change to (Locale.current.countryCode!)", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(ok);
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return;
        };
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let currentLocPlacemark = placemarks?.first else { return };
            self.countryCode = currentLocPlacemark.isoCountryCode ?? Locale.current.regionCode!;

        }
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
}
