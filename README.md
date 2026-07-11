# 🚗 ThrottleIQ

**ThrottleIQ** is a Flutter-based Smart Automotive Telemetry Dashboard designed to provide real-time vehicle tracking, trip analytics, driving insights, and route visualization using GPS data.

The application transforms a smartphone into a powerful automotive telemetry system capable of tracking speed, distance, routes, trip statistics, and driving behavior.



## ✨ Features

### 📍 Real-Time GPS Tracking

* Live vehicle speed monitoring
* High-accuracy GPS tracking
* Real-time location updates

### 🏁 Premium Analog Speedometer

* German-inspired analog cluster design
* Smooth needle animations
* Multiple drive modes
* Dark-themed automotive UI

### 🗺️ Route Visualization

* Google Maps integration
* Live location tracking
* Route replay after trip completion
* Start and end point visualization
* Travel path rendering using polylines

### 📊 Trip Analytics

* Distance travelled
* Average speed
* Top speed
* Travel duration
* ETA comparison
* Trip history management

### 🚘 Garage Management

* Add and manage vehicles
* Vehicle-wise trip tracking
* Overall vehicle statistics
* Total distance driven
* Total trips completed

### 👤 User Profile & Settings

* Profile customization
* Theme settings
* Unit conversion (KM/H ↔ MPH)
* Notification preferences

### 💾 Persistent Storage

* Trip history saving
* Vehicle information storage
* User preferences persistence
* Analytics preservation between app launches



## 🏗️ Project Architecture

ThrottleIQ follows a modular architecture:

```plaintext
lib/
├── core/
├── features/
├── models/
├── services/
├── utils/
├── widgets/
└── main.dart
```

### Main Components

* **GPS Service** – Handles real-time location tracking.
* **Telemetry Engine** – Processes speed and distance calculations.
* **Trip Management System** – Stores and analyzes completed trips.
* **Garage System** – Maintains vehicle data and statistics.
* **Analytics Engine** – Generates trip insights and performance metrics.
* **Settings Manager** – Handles themes, units, and preferences.

---

## 🛠️ Technologies Used



### Maps & Location

* Google Maps Flutter
* Geolocator

### UI & Animation

* Syncfusion Flutter Gauges
* Flutter Animate
* Google Fonts

### Storage

* Local Persistent Storage

### Development Tools

* Flutter SDK
* Android Studio / VS Code / Antigravity IDE
* Git & GitHub

---

## 🚀 Installation

### Clone Repository

```bash
git clone https://github.com/PrajitPranav/ThrottleIQ.git
```

### Navigate to Project

```bash
cd ThrottleIQ
```

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

---

## 📱 Supported Platforms

* Android
* iOS (Future Support)
* Web (Experimental)

---

## 🎯 Future Roadmap

### Phase 1

* Driving Behavior Analytics
* Harsh Braking Detection
* Acceleration Analysis
* Turn Detection
* Live Trip Timer

### Phase 2

* AI Driving Insights
* Smart Driving Score
* Efficiency Analysis
* Driving Recommendations

### Phase 3

* OBD-II Integration
* RPM Monitoring
* Engine Telemetry
* Fuel Analytics

### Phase 4

* Firebase Authentication
* Cloud Synchronization
* Multi-Device Support

### Phase 5 — Leaderboard Part

* Friend Circle Leaderboards
* Global Rankings
* Achievements System
* Real-Time Rank Updates
* Demotion Notifications
* Competitive Driving Community

---

## 📸 Screenshots

Add your application screenshots here.

```plaintext
screenshots/
├── dashboard.png
├── trip_history.png
├── analytics.png
├── garage.png
└── maps.png
```

---

## 🤝 Contributing

Contributions, suggestions, and feature requests are welcome.

Feel free to fork the repository and submit pull requests.

---

## 📄 License

This project is currently developed for educational, research, and automotive telemetry learning purposes.

---

## 👨‍💻 Developer

**PRAJIT PRANAB KARTHI KEYAN**

ThrottleIQ is a passion project focused on building a modern automotive telemetry ecosystem using Flutter and real-time GPS technologies.
