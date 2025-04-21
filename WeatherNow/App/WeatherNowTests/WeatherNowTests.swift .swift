//
//  WeatherNowTests.swift .swift
//  WeatherNow
//
//  Created by Edward on 21.04.2025.
//

import XCTest
@testable import WeatherNow

final class WeatherNowTests: XCTestCase {

    func testWeatherDataParsing() throws {
        let json = """
        {
            "name": "Москва",
            "main": {
                "temp": 21.5,
                "feels_like": 20.0
            },
            "weather": [
                {
                    "description": "ясно"
                }
            ],
            "wind": {
                "speed": 4.5
            }
        }
        """.data(using: .utf8)!

        do {
            let decoded = try JSONDecoder().decode(WeatherData.self, from: json)
            XCTAssertEqual(decoded.name, "Москва")
            XCTAssertEqual(decoded.main.temp, 21.5)
            XCTAssertEqual(decoded.weather.first?.description, "ясно")
            XCTAssertEqual(decoded.wind.speed, 4.5)
        } catch {
            XCTFail("Ошибка при парсинге: \(error.localizedDescription)")
        }
    }
}
