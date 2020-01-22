//
//  WeatherManager.swift
//  Clima
//
//  Created by ykson on 2019/11/12.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateLiveWeather(_ weatherManager: WeatherManager, liveWeather: LiveWeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let defaultURL = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/"
    let liveWeatherFilePath = "ForecastGrib"
    let serviceKey = "SK5dK/KaGBXSZE9Kr7J+qQCSJM9xh4fnLNB2XLvN/2rR+XZGfxF7svmgDW/PZ+nRTeaOmSOc6r97kzr9a+oPGg=="
    var delegate: WeatherManagerDelegate?
    static let sessionManager: URLSession = {
        let configure = URLSessionConfiguration.default
        configure.timeoutIntervalForRequest = 3
        configure.timeoutIntervalForResource = 3
        
        //< 2. Create a URL session
        return URLSession(configuration: configure)
    }()
    
    /**
        Get the Weather data
     */
    func getWeatherInfo(latitude: Double, longitude: Double) {
        //< get the currrent weather data
        getLiveWeather(latitude: latitude, longitude: longitude)
    }
    
    //< MARK: - 초딘기실황예보
    
    /**
        초단기실황 날씨정보
     */
    private func getLiveWeather(latitude: Double, longitude: Double) {
        if var urlComponents = URLComponents(string: defaultURL + liveWeatherFilePath) {
            //< get the current date information
            let dateInfo = DateUtils.shared.getDateInfo()
            //< set the base date
            let baseDate = String.init(format: "%04d%02d%02d", dateInfo.year, dateInfo.month, dateInfo.day)
            //< set the base time
            var baseTime: String?
            if dateInfo.minute <= 30 {
                baseTime = String.init(format: "%02d00", dateInfo.hour - 1)
            }
            else {
                baseTime = String.init(format: "%02d00", dateInfo.hour)
            }

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
            
            //< replace the specific character of query
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "/", with: "%2F")
            
            performLiveWeatherInfo(with: urlComponents.url!)
        }
    }
    
    func performLiveWeatherInfo(with url: URL) {
        print("request : \(url)")
        //< 3. Give the session a task
        let task = WeatherManager.sessionManager.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data {
                if let liveWeatherModel = self.parseLiveWeatherJSON(safeData) {
                    //< call the delegate function
                    self.delegate?.didUpdateLiveWeather(self, liveWeather: liveWeatherModel)
                }
                else {
                    //< if weather data model is nil then ...
                    print("How do i do?")
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
            print("response : \(decodedData)")
            //< check the result code
            if decodedData.response.header.resultCode != "0000" {
                print("Fail to getting weather data : \(decodedData.response.header.resultMsg)")
                return nil
            }
            
            //< check the count of item
            if decodedData.response.body!.totalCount <= 0 {
                print("Fail to getting weather data : not exist the weather data")
                return nil
            }
            
            //< create a live weather model
            var liveWeatherModel = LiveWeatherModel()
            
            //< set the data model
            for item in decodedData.response.body!.items!.item {
                switch item.category {
                case "PTY":
                    print("강수형태(\(item.category)) : \(item.obsrValue)")
                case "REH":
                    print("습도(\(item.category)) : \(item.obsrValue)")
                case "RN1":
                    print("1시간 강수량(\(item.category)) : \(item.obsrValue)")
                case "T1H":
                    liveWeatherModel.temperature = item.obsrValue
                    print("온도(\(item.category)) : \(item.obsrValue)")
                case "UUU":
                    print("동서바람성분(\(item.category)) : \(item.obsrValue)")
                case "VEC":
                    print("풍향(\(item.category)) : \(item.obsrValue)")
                case "VVV":
                    print("남북바람성분(\(item.category)) : \(item.obsrValue)")
                case "WSD":
                    print("풍속(\(item.category)) : \(item.obsrValue)")
                default:
                    print("Unknown category")
                }
            }

            //< TODO

            return liveWeatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
