# WeatherNow

Простое и удобное iOS-приложение для просмотра текущей погоды 🌤  
Работает по геолокации и названию города. Поддерживает кэш и выбор единиц измерения (°C / °F).

---

## 📝 Чек-лист реализации задания

- [x] Запрос разрешения на геолокацию  
- [x] Один экран с кнопкой прогноза по текущей геопозиции  
- [x] Обработка отказа в доступе к геопозиции (`locationPermissionDenied()`)  
- [x] Обработка отсутствия интернета (через `NetworkMonitor.shared.isConnected`)  
- [x] Поле ввода города + поиск погоды по названию  
- [x] Кэширование данных между сессиями (`UserDefaults`)  
- [x] Переключение между °C и °F (`UISegmentedControl`)  
- [x] Использование только нативных средств разработки (UIKit, CoreLocation и др.)  
- [x] Вся верстка сделана кодом (NSLayoutConstraint), без storyboard/xib  
- [x] Минимальное тестирование (`XCTestCase` на JSON-парсинг)

---

## ⚙️ Архитектура и стек

- UIKit
- MVC с разделением на модули (`Network`, `LocationManager`, `NetworkMonitor`, `Views`)
- Без сторонних библиотек
- Кеширование через `UserDefaults`
- Обработка ошибок через алерты

---

## 📁 Структура проекта

- `App` — AppDelegate, запуск приложения  
- `Views` — `WeatherViewController`  
- `Models` — `WeatherData.swift`  
- `Network` — `WeatherService`, `Constants`  
- `Utils` — `LocationManager`, `NetworkMonitor`  
- `Resources` — Assets и иконки  
- `Tests` — `WeatherNowTests.swift`

