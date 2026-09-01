# StudyMate AI — Study & Task Manager
### Complete Project Specification Document

---

## 1. App Overview

**StudyMate AI** ek iOS app hai jo students ko unke Courses, Topics, aur Tasks manage karne mein help karti hai — saath hi AI ka use karke notes summarize karna aur quiz questions generate karna.

**Target user:** College/school students jo apna study material organize karna chahte hain aur AI se quick revision chahte hain.

---

## 2. Tech Stack

| Category | Technology |
|---|---|
| Language | Swift |
| UI Framework | UIKit |
| Layout | Storyboard + AutoLayout |
| Navigation | UINavigationController + UITabBarController + UISplitViewController (iPad) |
| Local Persistence | CoreData |
| Lightweight Storage | UserDefaults |
| Networking | URLSession |
| Concurrency | async/await |
| Error Handling | Custom Error enums + do-catch |
| AI Integration | REST API call (OpenAI/Claude) via URLSession |

---

## 3. Core Concepts Used (aur kaha use honge)

| Concept | Kaha Use Hoga | Kyu |
|---|---|---|
| CoreData Entities & Relationships | Course → Topic → Task | Structured, related data persist karne ke liye |
| One-to-Many Relationship | Course→Topics, Topic→Tasks | Ek course ke multiple topics/tasks link karne ke liye |
| One-to-One Relationship | Topic → AISummary | Har topic ka ek hi AI summary store karne ke liye |
| UserDefaults | Theme (dark/light), AI toggle, last opened tab | Simple key-value settings ke liye |
| URLSession | AI API calls (summary, quiz generation) | Network requests ke liye |
| async/await | Saare API calls | Main thread block kiye bina background work |
| Error Handling | Network layer, JSON decoding | Crashes/blank states avoid karne ke liye |
| AutoLayout | Har screen | Multiple device sizes (iPhone/iPad) support |
| TabBarController | Root navigation | Top-level app sections |
| NavigationController | Course → Topic → Task drill-down | Hierarchical navigation |
| SplitViewController | iPad layout | Sidebar + detail view (adaptive) |

---

## 4. CoreData Model (Entities & Relationships)

### Entity: Course
- `id: UUID`
- `name: String`
- `colorTag: String`
- `createdAt: Date`
- **Relationship:** `topics` (to-many → Topic)

### Entity: Topic
- `id: UUID`
- `title: String`
- `deadline: Date?`
- **Relationship:** `course` (to-one → Course, inverse of `topics`)
- **Relationship:** `tasks` (to-many → Task)
- **Relationship:** `aiSummary` (to-one → AISummary, optional)

### Entity: Task
- `id: UUID`
- `title: String`
- `isDone: Bool`
- `notes: String?`
- **Relationship:** `topic` (to-one → Topic, inverse of `tasks`)

### Entity: AISummary
- `id: UUID`
- `content: String`
- `generatedAt: Date`
- **Relationship:** `topic` (to-one → Topic, inverse of `aiSummary`)

**Delete Rule:** Course delete → Cascade (uske Topics bhi delete), Topic delete → Cascade (uske Tasks bhi delete)

---

## 5. Screens (Total: 9 Screens)

| # | Screen | Type | Purpose |
|---|---|---|---|
| 1 | **Today** | TabBar item | Aaj ke pending tasks ka summary view |
| 2 | **Courses List** | TabBar item (root of NavController) | Saare courses ki list |
| 3 | **Course Detail (Topics List)** | Push screen | Ek course ke andar saare topics |
| 4 | **Topic Detail (Tasks List)** | Push screen | Ek topic ke andar saare tasks + AI summary button |
| 5 | **Task Detail / Add-Edit** | Modal / Push | Task add/edit karna |
| 6 | **AI Summary View** | Modal | AI-generated summary/quiz dikhana, loading & error states |
| 7 | **Stats** | TabBar item | Progress tracking (courses count, tasks completed %) |
| 8 | **Settings** | TabBar item | Theme toggle, AI on/off, about |
| 9 | **iPad Sidebar (SplitView)** | Adaptive | Sidebar mein courses, detail pane mein topics/tasks |

---

## 6. App Structure (Navigation Flow)

```
UITabBarController (Root)
│
├── Tab 1: Today
│     └── UIViewController (pending tasks overview)
│
├── Tab 2: Courses
│     └── UINavigationController
│           ├── CoursesListVC
│           │     └── (push) TopicsListVC
│           │           └── (push) TasksListVC
│           │                 ├── (push/modal) TaskDetailVC
│           │                 └── (modal) AISummaryVC
│
├── Tab 3: Stats
│     └── UIViewController (charts/progress)
│
└── Tab 4: Settings
      └── UIViewController (theme, toggles)

[iPad only] → UISplitViewController wraps Courses tab
      ├── Sidebar: CoursesListVC
      └── Detail: TopicsListVC / TasksListVC
```

---

## 7. Features

### Must-Have (Core)
- [ ] Course create/edit/delete (with color tag)
- [ ] Topic add/edit/delete under a course
- [ ] Task add/edit/delete/mark-complete under a topic
- [ ] AI Summary generation for a topic's notes (via API)
- [ ] AI Quiz question generation (optional extension of same API feature)
- [ ] Dark/Light theme toggle (UserDefaults)
- [ ] Today view — pending tasks across all courses (sorted by deadline)
- [ ] Basic stats — total courses, completion %

### Nice-to-Have (if time permits)
- [ ] Search bar in Courses/Topics
- [ ] Swipe-to-delete with UISwipeActionsConfiguration
- [ ] Local notifications for task deadlines
- [ ] iPad split-view adaptive layout

### Explicitly Out of Scope (v1)
- User authentication/login
- Cloud sync (iCloud/Firebase)
- Multi-user support

---

## 8. Design Guidelines

- **Style:** Clean, minimal, card-based lists (UITableView with custom cells)
- **Color scheme:** One accent color per course (colorTag), neutral background, supports Dark Mode natively
- **Typography:** System font (Dynamic Type support for accessibility)
- **Components:**
  - UITableView for Courses/Topics/Tasks lists
  - UIActivityIndicatorView during AI API calls
  - UIAlertController for errors and confirmations
  - Custom UITableViewCell with progress indicator (tasks completed / total)
- **AutoLayout approach:** Stack views inside cells, constraints pinned to safe area, adaptive for iPhone SE to iPad Pro

---

## 9. Error Handling Strategy

```swift
enum APIError: Error {
    case invalidURL
    case noInternet
    case serverError(String)
    case decodingFailed
}
```

- Network layer throws typed errors → caught in ViewController → shown via `UIAlertController`
- CoreData saves wrapped in `do-catch` → fallback to in-memory state + user-facing alert on failure
- Loading/Error/Success states managed explicitly on AI Summary screen (no silent failures)

---

## 10. Suggested Build Order (Milestones)

1. CoreData model + Course CRUD (list + add/edit/delete)
2. Topic entity + relationship + Topic screen
3. Task entity + relationship + Task screen
4. TabBar + Navigation structure wiring
5. UserDefaults settings (theme toggle)
6. URLSession + async/await AI API integration + error handling
7. Stats screen (computed from CoreData data)
8. AutoLayout polish + Dark Mode testing
9. (Optional) iPad SplitView adaptation

---

## 11. What to Explain to Mentor (Quick Reference)

- **Why CoreData relationships:** Real-world hierarchy (Course→Topic→Task) needs linked, queryable data — not flat/isolated storage.
- **Why async/await:** Keeps UI responsive during network calls; avoids callback nesting.
- **Why custom Error enum:** Different failure types (bad URL, server error, decoding) need different user-facing handling.
- **Why UserDefaults ≠ CoreData:** UserDefaults for simple flags/settings; CoreData for structured, relational data.
- **Why TabBar + NavigationController combo:** TabBar for top-level sections, NavigationController for drill-down hierarchy within a section.
