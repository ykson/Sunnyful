//
//  CurrentWeatherViewController.swift
//  Sunnyful
//
//  Created by leo on 2020/01/05.
//  Copyright © 2020 leo. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentWeatherViewController: UIViewController {
    var isStop: Bool = false
    var locationManager = CLLocationManager()
    var weatherManager = WeatherManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLocation()
        
        //< set the delegate of weather manager
        weatherManager.delegate = self
    }

    /**
     *  request the current location
     */
    func requestLocation() {
        locationManager.delegate = self
        //< request authrization
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}

//< MARK: - CLLocationManagerDelegate

extension CurrentWeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //< stop location manager
            self.locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            print("Get a location : lat=\(lat), lon=\(lon)")
            
            //< request a weather information
            if !isStop {
                //< get the weather information
                weatherManager.getWeatherInfo(latitude: lat, longitude: lon)
                //< change the flag
                isStop = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//< MARK: - Implement a WeatherManager delegate Methods

extension CurrentWeatherViewController: WeatherManagerDelegate {
    /**
        Update The 초단기실황예보
     */
    func didUpdateLiveWeather(_ weatherManager: WeatherManager, liveWeather: LiveWeatherModel) {
        DispatchQueue.main.async {
            print(liveWeather)
        }
    }
    
    /**
        Error
     */
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            print("Error : \(error)")
        }
    }
}
