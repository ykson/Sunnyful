//
//  LiveWeatherData.swift
//  Sunnyful
//
//  Created by leo on 2020/01/06.
//  Copyright © 2020 leo. All rights reserved.
//

import Foundation

struct LiveWeatherData: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct Header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct Body: Codable {
    let items: Items
    let totalCount: Int
}

struct Items: Codable {
    let item: [Item]
}

struct Item: Codable {
    let baseDate: Int
    let baseTime: BaseTimeType
    let category: String
    let obsrValue: Double
}

// Where I can represent all the types that the JSON property can be. (Int, String and so on...)
enum BaseTimeType: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()

        // Decode as Integer type
        do {
            let intVal = try container.decode(Int.self)
            self = .string(String(intVal))
        } catch DecodingError.typeMismatch {
            // Decode as String type
            let stringVal = try container.decode(String.self)
            self = .string(stringVal)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let value):
            try container.encode(String(value))
        case .string(let value):
            try container.encode(value)
        }
    }
}
