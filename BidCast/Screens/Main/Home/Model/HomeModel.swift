//
//  HomeModel.swift
//  Rise Shine Swing App
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

// MARK: - AlarmModel
struct AlarmModel: Codable {
    var userID: Int?
    var title, time: String?
    var days: [String]?
    var comment, status, updatedAt, createdAt: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title, time, days, comment, status
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}

// MARK: - deleteAlarmModel
struct deleteAlarmModel : Codable{
   
}

// MARK: - weatherModel
struct weatherModel : Codable{
   
}


// MARK: - CurrentWeatherModel
struct CurrentWeatherModel: Codable {
    var category, shortForecast: String?
    var temperature: Int?
    var temperatureUnit, windSpeed, windDirection: String?
    var icon: String?
    var dewpoint: Double?
    var humidity: String?
    var wind: WindData?
    var sunset: String?
}


// MARK: - WindData
struct WindData: Codable {
    var speed, direction: String?
}
