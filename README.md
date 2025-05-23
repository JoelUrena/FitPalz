# FitPalz: Gamified Fitness App

FitPalz is a gamified fitness tracker designed in Swift using SwiftUI, Firebase, and HealthKit. The app motivates users to stay active by earning XP, unlocking achievements and badges, and competing with friends on leaderboards. It is designed with expandability and Firebase integration in mind.

---

## 📆 Project Timeline

**Capstone Project • Spring 2025**
**Developer:** Joel Ureña
**Institution:** Hunter College • CUNY
**Language:** Swift 5
**Frameworks:** SwiftUI, Firebase Firestore, Combine, Contacts, UserNotifications, HealthKit

---

## 📊 Core Features

### ✨ Achievements & Badges

* Data-driven XP system based on JSON files (`achievements.json`, `badges.json`)
* Progress tracking via `XPSystem` class
* All achievements and badges are viewable in a unified gallery

### 📲 Contacts & Friends

* Sync iPhone contacts to discover FitPalz users
* Invite new users via SMS
* Add and manage friends
* Friends are visible in a dedicated leaderboard and friends tab

### 🏋️ Leaderboards

* Two leaderboard modes: Weekly & All-time
* Sorted by XP
* Displays user rank, XP, achievements, badges
* Includes sections for Top 10, Your Rank, and Your Friends

### 🔹 Achievement Transaction System (ATS)

* Displays unlock history of achievements & badges
* Ordered by most recent
* Highlights the most recently earned reward
* Fully navigable from the Achievement Gallery

### 🔔 Local Notifications

* Alerts user when they unlock an achievement or badge
* Powered by `UserNotifications`

---

## 📂 Project Structure

* `Xp_System.swift`: Core XP/Badge engine, unlock logic, and gallery
* `AchievementGalleryView.swift`: UI to display badge/achievement catalog
* `AchievementHistoryView.swift`: UI to show unlock history with timestamps
* `LeaderboardView.swift`: Competitive XP leaderboard UI
* `Contacts_System.swift`: Permissions and logic to parse local contacts
* `ProfileCard.swift`: View that displays a user's level, XP, and avatar
* `MainTabView.swift`: Bottom navigation bar with tabs for Home, Leaderboard, Friends, and Achievements
* `FirebaseSyncService.swift`: (Optional) One-way sync scaffold for Firebase ➞ app

---

## ⚖️ Technologies

* **Firebase Firestore:** For syncing user XP, history, and gallery assets
* **SwiftUI:** View layer and navigation stack
* **HealthKit (optional):** Future integration for fitness stats like steps
* **UserNotifications:** Local push alerts for unlocked achievements
* **Contacts:** Access iOS contacts for invite/lookup

---

## 🚀 Deployment Instructions for Professor

### ✅ Requirements

* Xcode 15+
* iOS Simulator or real device (iOS 17+ recommended)
* Firebase setup (you may skip this step for offline testing)
* In Xcode -> Signing & Capabilities, make sure HealthKit is enabled
* Ensure the following keys are present if not already in Info.plist:
    key: NSHealthShareUsageDescription
     This app uses HealthKit to read your health data.</string>
    key: NSHealthUpdateUsageDescription</key>
     This app writes your fitness data to HealthKit.</string>

### Ἶ0 Build Steps

1. Open `Fitpalzsz.xcodeproj` in Xcode.
2. Select a simulator (e.g., iPhone 15 Pro).
3. Run the app (Cmd + R).
4. The app will open to the **Sign Up / Login** screen.

### 🗺 Navigation Demo

* **Achievement Gallery Tab**:

  * View all available Achievements & Badges
  * Tap "History" in the top-right to access the **Achievement Transaction System** (ATS)
* **Friends Tab**:

  * Add friends from your contacts
  * Friends show XP and earned rewards
* **Leaderboard Tab**:

  * Toggle between All-Time and Weekly modes
  * Check your own rank and see how your friends compare
* **Home Tab**:

  * Displays a profile card showing your XP, Level, and stats

### 🎨 Notes

* The XP system is based on total earned achievements and badges
* The ProfileCard updates based on live Firebase values
* If the achievement gallery is empty, make sure `achievements.json` and `badges.json` are in the project with target membership enabled

---

## 📅 Final Notes

This project was designed to allow plug-and-play scalability for future Firebase teams and is modular in its architecture. Any logic can be swapped out or extended without refactoring existing views.

