//
//  WeatherView.swift
//  WeatherNow
//
//  Created by Edward on 21.04.2025.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    let weatherService = WeatherService()
    
    private let locationButton = UIButton(type: .system)
    private let cityTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "🌆 Введите город"
        field.font = UIFont.systemFont(ofSize: 16)
        field.backgroundColor = .white
        field.borderStyle = .roundedRect
        field.layer.cornerRadius = 10
        field.layer.shadowColor = UIColor.gray.cgColor
        field.layer.shadowOpacity = 0.2
        field.layer.shadowOffset = CGSize(width: 0, height: 2)
        field.layer.shadowRadius = 4
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    private let citySearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔍 Погода по городу", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let unitControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["°C", "°F"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .systemGray6
        control.selectedSegmentTintColor = .white
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private var selectedUnit: String {
        return unitControl.selectedSegmentIndex == 0 ? "metric" : "imperial"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        title = "WeatherNow"
        
        setupUI()
        LocationManager.shared.delegate = self
        
        if let cached = weatherService.loadCachedWeather() {
            showWeatherResult(.success(cached), titlePrefix: "Кешировано")
        }
    }
    
    private func setupUI() {
        locationButton.setTitle("📍 Погода по геопозиции", for: .normal)
        locationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        locationButton.backgroundColor = .systemBlue
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.layer.cornerRadius = 12
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOpacity = 0.2
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        locationButton.layer.shadowRadius = 6
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.addTarget(self, action: #selector(requestWeatherByLocation), for: .touchUpInside)

        view.addSubview(unitControl)
        view.addSubview(locationButton)
        view.addSubview(cityTextField)
        view.addSubview(citySearchButton)

        citySearchButton.addTarget(self, action: #selector(requestWeatherByCity), for: .touchUpInside)

        NSLayoutConstraint.activate([
            unitControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            unitControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unitControl.widthAnchor.constraint(equalToConstant: 160),

            locationButton.topAnchor.constraint(equalTo: unitControl.bottomAnchor, constant: 40),
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationButton.widthAnchor.constraint(equalToConstant: 260),
            locationButton.heightAnchor.constraint(equalToConstant: 50),

            cityTextField.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 30),
            cityTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityTextField.widthAnchor.constraint(equalToConstant: 260),
            cityTextField.heightAnchor.constraint(equalToConstant: 45),

            citySearchButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 20),
            citySearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            citySearchButton.widthAnchor.constraint(equalToConstant: 260),
            citySearchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemTeal.cgColor, UIColor.systemBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    @objc private func requestWeatherByLocation() {
        guard NetworkMonitor.shared.isConnected else {
            showAlert(title: "Нет интернета", message: "Проверьте подключение к сети.")
            return
        }
        LocationManager.shared.requestLocation()
    }
    
    @objc private func requestWeatherByCity() {
        guard let city = cityTextField.text, !city.isEmpty else { return }

        guard NetworkMonitor.shared.isConnected else {
            showAlert(title: "Нет интернета", message: "Проверьте подключение к сети.")
            return
        }

        weatherService.fetchWeather(for: city, units: selectedUnit) { result in
            DispatchQueue.main.async {
                self.showWeatherResult(result)
            }
        }
    }

    private func showWeatherResult(_ result: Result<WeatherData, Error>, titlePrefix: String? = nil) {
        switch result {
        case .success(let weatherData):
            let temp = weatherData.main.temp
            let desc = weatherData.weather.first?.description ?? "Нет описания"
            let city = weatherData.name
            let unitSymbol = selectedUnit == "metric" ? "°C" : "°F"
            let title = titlePrefix != nil ? "\(titlePrefix!): \(city)" : city

            let alert = UIAlertController(
                title: title,
                message: "Температура: \(temp)\(unitSymbol)\n\(desc.capitalized)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)

        case .failure(let error):
            showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LocationManagerDelegate

extension WeatherViewController: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        guard NetworkMonitor.shared.isConnected else {
            showAlert(title: "Нет интернета", message: "Проверьте подключение к сети.")
            return
        }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        weatherService.fetchWeather(lat: lat, lon: lon, units: selectedUnit) { result in
            DispatchQueue.main.async {
                self.showWeatherResult(result)
            }
        }
    }

    func didFailWithError(_ error: Error) {
        print("Ошибка получения геопозиции: \(error.localizedDescription)")
    }

    func locationPermissionDenied() {
        showAlert(title: "Геопозиция отключена", message: "Включите доступ к геопозиции в настройках, чтобы получить прогноз.")
    }
}


