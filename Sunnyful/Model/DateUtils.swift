//
//  DateUtils.swift
//  Sunnyful
//
//  Created by leo on 2020/01/07.
//  Copyright © 2020 leo. All rights reserved.
//

import Foundation

struct DateUtils {
    static let shared: DateUtils = {
        let instance = DateUtils()
        
        return instance
    }()
    
    private init() {}
    
    struct DateInfo {
        var year: Int = 0
        var month: Int = 0
        var day: Int = 0
        var hour: Int = 0
        var minute: Int = 0
        var second: Int = 0
    }
    
    func getFormattedDate(date: Date, format: String) -> String {
        //< create a formatter
        let formatter = DateFormatter()
        //< set the date format
        formatter.dateFormat = format
        //< convert the date to formatted date string
        let date = formatter.string(from: date)
        
        return date
    }
    
    
    func getDateInfo() -> DateInfo {
        //< get the current date
        let date = Date()
        //< create the calendar
        let calendar = Calendar.current
        //< create the date struct
        var dateInfo = DateInfo()
        
        //< set the year
        dateInfo.year = calendar.component(.year, from: date)
        //< set the month
        dateInfo.month = calendar.component(.month, from: date)
        //< set the day
        dateInfo.day = calendar.component(.day, from: date)
        //< set the hour
        dateInfo.hour = calendar.component(.hour, from: date)
        //< set the minute
        dateInfo.minute = calendar.component(.minute, from: date)
        //< set the second
        dateInfo.second = calendar.component(.second, from: date)
        
        return dateInfo
    }
}
