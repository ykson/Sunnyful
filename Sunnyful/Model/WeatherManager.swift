//
//  WeatherManager.swift
//  Clima
//
//  Created by ykson on 2019/11/12.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
//    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let defaultURL = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/"
    let liveWeatherFilePath = "ForecastGrib"
    let serviceKey = "SK5dK/KaGBXSZE9Kr7J+qQCSJM9xh4fnLNB2XLvN/2rR+XZGfxF7svmgDW/PZ+nRTeaOmSOc6r97kzr9a+oPGg=="
    var delegate: WeatherManagerDelegate?
    
    /**
        초단기실황 날씨정보
     */
    func getLiveWeather(latitude: Double, longitude: Double) {
        if var urlComponents = URLComponents(string: defaultURL + liveWeatherFilePath) {
            //< get the current date information
            let dateInfo = DateUtils.shared.getDateInfo()
            //< set the base date
            let baseDate = String.init(format: "%04d%02d%02d", dateInfo.year, dateInfo.month, dateInfo.day)
            //< set the base time
            let baseTime = String.init(format: "%02d00", dateInfo.hour)
            
            print(baseTime)
            
            //< convert the latitude and longitude to X, Y
            let locationXY = LamcUtils.shared.convertGRID_GPS(toXY: true, lat_x: latitude, lot_y: longitude)
            
            //< set a parameters
            urlComponents.queryItems = [
                URLQueryItem(name: "serviceKey", value: serviceKey),
                URLQueryItem(name: "base_date", value: baseDate),
                URLQueryItem(name: "base_time", value: baseTime),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "nx", value: String(locationXY.x)),
                URLQueryItem(name: "ny", value: String(locationXY.y)),
                URLQueryItem(name: "pageNo", value: "1"),
                URLQueryItem(name: "numOfRows", value: "500")
            ]
            
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "/", with: "%2F")
            
            performWeather(with: urlComponents.url!)
        }
    }
    
    func performWeather(with url: URL) {
        print("request : \(url)")
        //< Create a configuration of URL session
        let configure = URLSessionConfiguration.default
        configure.timeoutIntervalForRequest = 3
        configure.timeoutIntervalForResource = 3
        
        //< 2. Create a URL session
        let sessoin = URLSession(configuration: configure)
        
        //< 3. Give the session a task
        let task = sessoin.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data {
                if let weatherModel = self.parseLiveWeatherJSON(safeData) {
                    //< call the delegate function
//                    self.delegate?.didUpdateWeather(self, weather: weatherModel)
                }
            }
        }
        
        //< 4. Start the task
        task.resume()
    }
    
    func parseLiveWeatherJSON(_ weatherData: Data) -> LiveWeatherModel? {
        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(LiveWeatherData.self, from: weatherData)
            print(decodedData)

            //< get a weather model
            let liveWeatherModel = LiveWeatherModel(temperature: 0.0)

            return liveWeatherModel
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
