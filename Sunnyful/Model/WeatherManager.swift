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
        초단기실황
     */
    func getLiveWeather(latitude: Double, longitude: Double) {
        if var urlComponents = URLComponents(string: defaultURL + liveWeatherFilePath) {
            //< set a parameters
            urlComponents.queryItems = [
                URLQueryItem(name: "serviceKey", value: serviceKey),
                URLQueryItem(name: "base_date", value: "20200106"),
                URLQueryItem(name: "base_time", value: "0600"),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "nx", value: "62"),
                URLQueryItem(name: "ny", value: "125"),
                URLQueryItem(name: "pageNo", value: "1"),
                URLQueryItem(name: "numOfRows", value: "500")
            ]
            
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "/", with: "%2F")
            
            performWeather(with: urlComponents.url!)
        }
    }
    
    func performWeather(with url: URL) {
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
            print(decodedData.response.body.items.item[0].baseTime)

            //< get a weather model
            let liveWeatherModel = LiveWeatherModel(temperature: 0.0)

            return liveWeatherModel
        } catch {
            print(error.localizedDescription)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
