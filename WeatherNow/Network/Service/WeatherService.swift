//
//  WeatherService.swift
//  WeatherNow
//
//  Created by Edward on 21.04.2025.
//

import Foundation
import CoreLocation

final class WeatherService {
    
    private let cacheKey = "cachedWeatherData"
    
    /// Запрос по названию города
    func fetchWeather(
        for city: String,
        units: String = "metric",
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityQuery)&appid=\(Constants.weatherAPIKey)&units=\(units)&lang=ru"
        fetch(from: urlString, completion: completion)
    }

    /// Запрос по координатам
    func fetchWeather(
        lat: Double,
        lon: Double,
        units: String = "metric",
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(Constants.weatherAPIKey)&units=\(units)&lang=ru"
        fetch(from: urlString, completion: completion)
    }

    /// Загрузка закешированных данных
    func loadCachedWeather() -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey), !data.isEmpty else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(WeatherData.self, from: data)
        } catch {
            print("❗️Ошибка декодирования закешированных данных: \(error)")
            return nil
        }
    }

    /// Универсальный метод запроса + кеширование
    private func fetch(
        from urlString: String,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            // Проверка на ошибку в JSON (например, city not found)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let code = json["cod"] as? Int, code != 200 {
                let message = json["message"] as? String ?? "Unknown error"
                let apiError = NSError(domain: "Weather API", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                completion(.failure(apiError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                
                // 💾 Кешируем результат
                let encoded = try JSONEncoder().encode(decoded)
                UserDefaults.standard.set(encoded, forKey: self.cacheKey)
                
                completion(.success(decoded))
            } catch {
                print("❗️Ошибка декодирования полученных данных: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
