# 🎓 StudyMate AI — Modern iOS Study & Task Management App

[![iOS](https://img.shields.io/badge/iOS-14.3%2B-blue?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift&logoColor=white)](https://swift.org/)
[![UI Framework](https://img.shields.io/badge/UI-100%25%20Programmatic%20UIKit-purple?logo=uikit)](https://developer.apple.com/documentation/uikit)
[![Architecture](https://img.shields.io/badge/Architecture-No%20Storyboards%20%7C%20AutoLayout-darkcyan)](https://developer.apple.com/)
[![Database](https://img.shields.io/badge/Storage-Core%20Data-green)](https://developer.apple.com/documentation/coredata)
[![AI Engine](https://img.shields.io/badge/AI%20Engine-Google%20Gemini%20API-blueviolet?logo=google)](https://ai.google.dev/)

> **StudyMate AI** is a production-grade, offline-first iOS academic productivity app built **100% programmatically in Swift & UIKit without Storyboards**. It is powered by **Core Data** and **Google Gemini AI**, offering students a structured hierarchical coursework flow (**Course ➔ Module ➔ Lesson ➔ Notes**), an interactive ChatGPT-style AI study tutor, automated dynamic quiz generation with tap-to-reveal answers, and comprehensive study analytics.

---

## 💡 Architectural Highlight: 100% Programmatic UI (No Storyboards)

This project completely eliminates **Main.storyboard** and **Interface Builder (XIB)** files in favor of pure, clean, and maintainable programmatic Swift code:
* **Zero Merge Conflicts:** No complex XML conflict resolution in team Git workflows.
* **Declarative Auto Layout:** Built entirely using modern `NSLayoutConstraint` anchors and dynamic `UIStackView` layouts.
* **Dynamic Self-Sizing Cells:** Custom table view cells with automatic dimension sizing for rich AI responses and collapsible quiz cards.
* **Programmatic Navigation & Hierarchy:** Window, TabBar, and Navigation Controllers are cleanly initialized and bound in `SceneDelegate.swift`.
* **High Performance:** Instant view instantiations without storyboard XML decoding overhead.

---

## 📱 App Flow & Architecture Hierarchy

```
📚 Course (e.g. Data Structures & Algorithms, Operating Systems)
   └── 📖 Topic / Module (e.g. Binary Search Trees, Memory Management)
        └── 📝 Lesson / Task (e.g. Tree Traversal, Paging & Segmentation)
             ├── 📄 Notes Reader (Paginated study notes & lessons)
             ├── 🤖 AI Study Tutor (Context-aware Q&A grounded in student notes)
             ├── ⚡ AI Instant Revision Summary (Bullet points, key formulas, takeaways)
             └── 🎯 Interactive Practice Quiz (Dynamic MCQs with tap-to-reveal answers)
```

---

## ✨ Key Features

### 1. 📅 Tab 1: Study Planner & Timeline
* **Timeframe Filters:** Segmented pill bar allowing quick switching across **Today, Tomorrow, This Week, This Month, and All Tasks**.
* **Daily Streak & Motivation:** Live streak counter with animated fire badge and motivational progress metrics.
* **Interactive Checkbox:** Spring-animated completion toggle with automatic strikethrough styling and haptic feedback.

### 2. 📚 Tab 2: Courses & Deep Coursework
* **Level 1 — Courses:** Course cards with custom color themes, progress gauges, and lesson counters.
* **Level 2 — Topics / Modules:** Course sub-modules with completion percentages and deadline status badges (Overdue, Today, Tomorrow).
* **Level 3 — Tasks & Lessons:** Granular study tasks with priority tags (High, Medium, Low) and notes preview.
* **Level 4 — Task Notes Reader:** Full-featured study notes workspace with multi-page support.

### 3. 🤖 Interactive AI Study Tutor & Quiz Generator
* **Context-Aware Q&A:** Chat with an AI tutor that specifically reads the notes written for that module to answer questions accurately.
* **Instant Revision Summarizer:** Generates executive chapter summaries, formulas, and rapid revision checklists in one tap.
* **Practice Quiz Mode:** Dynamically generates multiple-choice questions (MCQs) tailored to notes length, featuring hidden answers with interactive reveal buttons and explanations.
* **Direct Save to Core Data:** One-tap button to persist generated summaries directly into local Core Data.

### 4. 📊 Tab 3: Study Analytics & Mastery Insights
* **Mastery Gauge:** Visual breakdown of completed lessons vs pending modules.
* **Key Metric Grid:** Active courses, total lessons, completed tasks, and current streaks.
* **Study Tips Card:** Dynamic academic advice that adapts based on user completion rate.

### 5. ⚙️ Tab 4: Settings & Customization
* **Appearance Engine:** Live theme toggle supporting **System, Light Mode, and Dark Mode** using `UserDefaultsManager`.
* **AI API Key Management:** Flexible configuration allowing users to input their own Google Gemini API key.
* **Sample Data Seeder:** One-tap button to load structured mock courses and notes for instant testing and demonstration.
* **Reset & Cleanup:** Safe database clearing and reset options.

---

## 📂 Codebase Structure

```
📁 studyMate/
│
├── 📂 App Lifecycle & Setup/
│   ├── AppDelegate.swift                  # Application lifecycle & background context triggers
│   ├── SceneDelegate.swift                # Programmatic UIWindow, TabBar & Navigation hierarchy setup
│   ├── SplashScreenViewController.swift   # Animated launch logo, glow aura & cross-dissolve transition
│   └── Info.plist                         # App bundle configuration
│
├── 📂 Screens & Controllers/
│   ├── TodayViewController.swift          # Tab 1: Study planner timeline with pill segment bar
│   ├── CoursesListViewController.swift    # Tab 2 (L1): Courses grid with progress calculation
│   ├── TopicsListViewController.swift     # Tab 2 (L2): Course modules & topic management
│   ├── TasksListViewController.swift      # Tab 2 (L3): Lesson tasks list & AI action triggers
│   ├── TaskDetailViewController.swift     # Tab 2 (L4): Lesson details, priority, deadlines & notes
│   ├── AISummaryViewController.swift      # ChatGPT-style AI study tutor with practice quizzes
│   ├── StatsViewController.swift          # Tab 3: Study analytics, mastery progress & charts
│   └── SettingsViewController.swift       # Tab 4: Theme switcher, API configuration & data tools
│
├── 📂 Custom Views & Cells/
│   ├── CourseCell.swift                   # Programmatic course card with dynamic progress bar
│   ├── TopicCell.swift                    # Module card with deadline chip & lesson count badge
│   └── TaskCell.swift                     # Lesson row with spring animated checkbox & strikethrough
│
├── 📂 Services & Networking/
│   ├── AIService.swift                    # Google Gemini REST API integration via URLSession
│   └── APIError.swift                     # Strongly-typed network and decoding errors
│
├── 📂 Persistence & Database/
│   ├── CoreDataManager.swift             # Centralized Core Data CRUD manager (Course, Topic, Task, AISummary)
│   ├── UserDefaultsManager.swift          # Key-Value store for Themes, Streaks, and App preferences
│   └── studyMate.xcdatamodeld             # CoreData SQLite relational schema with cascade deletion rules
│
└── 📂 Utilities & Helpers/
    ├── Extensions.swift                   # UIView card styling, HapticHelper, toast popups & date formats
    └── ColorHelper.swift                  # Design system color palettes, hex helpers & gradients
```

---

## 🛠️ Technical Specifications

| Parameter | Details |
| :--- | :--- |
| **Language** | Swift 5.0+ |
| **UI Framework** | **100% Programmatic UIKit** (Auto Layout, No Storyboards) |
| **Minimum iOS Target** | iOS 14.3+ (Fully compatible with iOS 15, 16, 17, 18) |
| **Local Database** | Core Data (SQLite relational schema with Cascade delete rules) |
| **Networking** | Native `URLSession` data tasks (Zero 3rd-party dependencies) |
| **AI Integration** | Google Generative Language REST API (`Gemini 1.5/2.0/3.7`) |
| **Architecture** | MVC with Service & Manager layers, Singleton patterns, Delegation & Completion closures |
| **Haptics** | `UIImpactFeedbackGenerator` & `UINotificationFeedbackGenerator` |

---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/dev-rajat1/studyMate.git
cd studyMate
```

### 2. Open project in Xcode
```bash
open studyMate.xcodeproj
```

### 3. Build & Run
1. Select an iOS Simulator (e.g., **iPhone 15 Pro** / **iPhone 16**) or your connected iOS device.
2. Press **`Cmd + R`** to build and run.
3. If launched on an empty simulator, go to **Settings (Tab 4)** ➡️ tap **"🌱 Load Sample Study Data"** to instantly populate realistic sample courses, topics, and lesson notes!

---

## 🔑 AI API Setup

1. Launch StudyMate and open **Settings (Tab 4)**.
2. Enter your **Google Gemini API Key** (from [Google AI Studio](https://aistudio.google.com/)).
3. Tap **Save API Key**. You're now ready to use the AI Study Tutor and Practice Quiz generator!

---

## 👨‍💻 Author & Contributions

* **Developer:** [Rajat](https://github.com/dev-rajat1)
