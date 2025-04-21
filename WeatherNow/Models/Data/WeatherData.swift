//
//  WeatherData.swift
//  WeatherNow
//
//  Created by Edward on 21.04.2025.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind

    struct Main: Codable {
        let temp: Double
        let feels_like: Double
    }

    struct Weather: Codable {
        let description: String
    }

    struct Wind: Codable {
        let speed: Double
    }
}
