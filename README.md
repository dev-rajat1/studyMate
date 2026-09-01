# 🎓 StudyMate AI — Smart Study & Task Manager for iOS

[![iOS](https://img.shields.io/badge/iOS-14.3%2B-blue?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift&logoColor=white)](https://swift.org/)
[![UI Framework](https://img.shields.io/badge/UI-UIKit%20%2B%20Storyboards-purple)](https://developer.apple.com/documentation/uikit)
[![Database](https://img.shields.io/badge/Storage-Core%20Data-green)](https://developer.apple.com/documentation/coredata)
[![AI Model](https://img.shields.io/badge/AI%20Engine-Gemini%203.7%20Flash-blueviolet?logo=google)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

> **StudyMate AI** is a modern, offline-first iOS study management app built with **Swift, UIKit, and Core Data**, powered by **Google Gemini 3.7 Flash AI**. It helps students structure coursework hierarchically (**Course ➡️ Module ➡️ Lesson ➡️ Notes**), generates tailored multi-question practice quizzes based on notes length, and tracks real-time academic productivity.

---

## 📱 App Highlights & Architecture Flow

```
📚 Course (e.g. Data Structures & Algorithms)
   └── 📖 Module (e.g. Module 1: Binary Search Trees)
        └── 📝 Lesson (e.g. Lesson 1: Tree Traversal)
             ├── 📄 Multi-Page Notes Reader (Page 1 of N)
             ├── 🤖 AI Deep Revision Summary
             └── 🎯 Scalable Practice Quiz (MCQs scaled to notes length)
```

---

## ✨ Key Features

### 1. 🎯 4-Level Academic Hierarchy
* **Level 1 — Courses:** Create study courses with custom color tags, progress bars, and module counters.
* **Level 2 — Modules:** Organize sub-topics within each course with persistent header breadcrumbs.
* **Level 3 — Lessons:** Manage individual lessons, target deadlines, and completion states.
* **Level 4 — Paginated Notes:** Full-screen distraction-free notes notebook with `[◀ Prev]` `📄 Page 1 of N` `[Next ▶]` `[➕ Add Page]` navigation.

### 2. 🤖 Gemini 3.7 Flash AI Study Assistant
* **Dynamic Quiz Scaling:** Automatically analyzes the depth and length of student notes to generate **4 to 18+ high-yield Multiple Choice Questions (MCQs)** with correct answers and explanations.
* **Comprehensive Revision Summaries:** Executive overview, key takeaways per lesson, formulas & definitions, common pitfalls, and rapid revision checklists.
* **Offline-First Fallback:** Seamlessly generates simulated revision material even without an active internet connection.

### 3. 🗓️ Today's Focus Dashboard (Tab 1)
* Live greeting card with today's formatted date and daily streak indicator.
* Filtered pending lessons with interactive checkmark tap scaling and haptic feedback.

### 4. 📊 Visual Study Analytics (Tab 3)
* Real-time **Overall Progress Gauge** with animated progress bar and completion rate.
* **4-Metric Study Matrix:** Active Courses, Total Modules, Total Lessons, and Completed Tasks.
* Dynamic motivational feedback adapting to study milestones.

### 5. 🎨 Modern Design & Micro-Animations
* Staggered **glide-in entrance animations** on TableView cells.
* Spring-scale touch feedback on card interactions.
* Support for **Light, Dark, and System Theme** modes.
* Floating haptic HUD toast notifications.

---

## 📂 Project Architecture

```
📁 studyMate/
│
├── 📂 App & Resources/
│   ├── AppDelegate.swift               # App Lifecycle & CoreData context initialization
│   ├── SceneDelegate.swift             # Window scene setup & background save triggers
│   ├── Main.storyboard                 # Clean, responsive Interface Builder layouts
│   ├── LaunchScreen.storyboard         # Splash screen with branding & Gemini badge
│   ├── Assets.xcassets                 # Color palettes, icons, and asset catalog
│   └── Info.plist                      # Application configuration properties
│
├── 📂 Controllers/
│   ├── TodayViewController.swift       # Tab 1: Today's Focus & pending study dashboard
│   ├── CoursesListViewController.swift # Tab 2 (L1): Courses list with progress tracking
│   ├── TopicsListViewController.swift  # Tab 2 (L2): Course Modules & persistent banner
│   ├── TasksListViewController.swift   # Tab 2 (L3): Module Lessons & AI trigger
│   ├── TaskDetailViewController.swift  # Tab 2 (L4): Full-screen Paginated Notes reader
│   ├── AISummaryViewController.swift   # AI Assistant modal for Summaries & Quizzes
│   ├── StatsViewController.swift       # Tab 3: Study Analytics & 4-metric matrix
│   └── SettingsViewController.swift    # Tab 4: Theme, AI API Key, & Data management
│
├── 📂 Views & Cells/
│   ├── CourseCell.swift                # Course card with color pill & progress bar
│   ├── TopicCell.swift                 # Module card with deadline badge & progress
│   └── TaskCell.swift                  # Lesson card with animated checkbox
│
├── 📂 Services & AI/
│   ├── AIService.swift                 # Gemini 3.7 Flash API URLSession integration
│   └── APIError.swift                  # Strongly-typed API error definitions
│
├── 📂 Managers & CoreData/
│   ├── CoreDataManager.swift          # Centralized CRUD operations & progress math
│   ├── UserDefaultsManager.swift       # App preferences, theme state, & API keys
│   └── studyMate.xcdatamodeld          # CoreData SQLite Entities (Course, Topic, Task, AISummary)
│
└── 📂 Helpers & Extensions/
    ├── Extensions.swift                # Micro-animations, haptic feedback, toast alerts
    └── ColorHelper.swift               # Accent color palette mapping
```

---

## 🛠️ Tech Stack & Requirements

| Technology | Specification |
| :--- | :--- |
| **Language** | Swift 5.0+ |
| **UI Framework** | UIKit (Storyboard + AutoLayout Constraints) |
| **Minimum iOS Target** | iOS 14.3+ (Supports iOS 15, 16, 17, 18) |
| **Database** | Core Data (SQLite Persistent Store with Cascade Rules) |
| **Networking** | Standard `URLSession` dataTask (no heavy 3rd-party dependencies) |
| **AI Integration** | Google Generative Language REST API (`gemini-3.7-flash`) |
| **Design Patterns** | MVC, Singleton, Delegation, Completion Closures |

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/dev-rajat1/studyMate.git
cd studyMate
```

### 2. Open in Xcode
Open `studyMate.xcodeproj` in Xcode (Xcode 14 / 15 / 16 recommended on macOS).

```bash
open studyMate.xcodeproj
```

### 3. Build & Run
1. Select an iOS Simulator (e.g., **iPhone 15 Pro** or **iPhone 16**) or a physical device.
2. Press **`Cmd + R`** to build and run.
3. Tap **Tab 4 (Settings)** ➡️ **"🌱 Load Sample Study Data"** to immediately populate courses, modules, lessons, and sample notes for testing!

---

## 🔑 AI API Configuration

StudyMate AI comes pre-configured with support for **Google Gemini 3.7 Flash**:
1. Open the app and navigate to **Settings (Tab 4)**.
2. Enter your Gemini API key in the **Gemini API Key** field and tap **Save API Key**.
3. *Note: If no custom key is provided, the app will smoothly fallback to its intelligent offline study simulator.*

---

## 👨‍💻 Author & Credits

* **Developer:** Rajat ([@dev-rajat1](https://github.com/dev-rajat1))
* **Architecture:** Native Swift UIKit with Core Data & Google Gemini AI.

---

## 📄 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
