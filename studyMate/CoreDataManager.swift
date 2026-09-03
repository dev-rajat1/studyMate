//
//  CoreDataManager.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Centralized manager for all CoreData database operations (CRUD).
//

import UIKit
import CoreData

// MARK: - Study Planner Timeframe
enum StudyTimeframe: Int, CaseIterable {
    case today = 0
    case tomorrow = 1
    case thisWeek = 2
    case thisMonth = 3
    case all = 4
    
    var title: String {
        switch self {
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .all: return "All Tasks"
        }
    }
}

// MARK: - Deep Subject Mastery Insight
struct CourseMasteryInsight {
    let course: Course
    let totalLessons: Int
    let completedLessons: Int
    let progress: Float
    let moduleCount: Int
    let colorTag: String
    let aiSummaryCount: Int
}

class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "studyMate")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("❌ CoreData Error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    /// Saves any pending changes in the Core Data context safely
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreData: Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("❌ CoreData Save Error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Course Operations
    
    /// Fetches all courses sorted by creation date (newest first)
    func fetchCourses() -> [Course] {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch courses: \(error)")
            return []
        }
    }
    
    /// Creates a new course and saves it
    @discardableResult
    func createCourse(name: String, colorTag: String) -> Course {
        let course = Course(context: context)
        course.id = UUID()
        course.name = name
        course.colorTag = colorTag
        course.createdAt = Date()
        saveContext()
        return course
    }
    
    /// Updates course details
    func updateCourse(_ course: Course, name: String, colorTag: String) {
        course.name = name
        course.colorTag = colorTag
        saveContext()
    }
    
    /// Deletes a course (cascade deletes all related topics and tasks)
    func deleteCourse(_ course: Course) {
        context.delete(course)
        saveContext()
    }
    
    // MARK: - Topic Operations
    
    /// Fetches all topics for a specific course
    func fetchTopics(for course: Course) -> [Topic] {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        request.predicate = NSPredicate(format: "course == %@", course)
        request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch topics: \(error)")
            return []
        }
    }
    
    /// Creates a new topic under a course
    @discardableResult
    func createTopic(title: String, deadline: Date? = nil, course: Course) -> Topic {
        let topic = Topic(context: context)
        topic.id = UUID()
        topic.title = title
        topic.deadline = deadline
        topic.course = course
        saveContext()
        return topic
    }
    
    /// Updates an existing topic
    func updateTopic(_ topic: Topic, title: String, deadline: Date? = nil) {
        topic.title = title
        if let deadline = deadline {
            topic.deadline = deadline
        }
        saveContext()
    }
    
    /// Deletes a topic (cascade deletes all related tasks and AI summary)
    func deleteTopic(_ topic: Topic) {
        context.delete(topic)
        saveContext()
    }
    
    // MARK: - Task Operations
    
    /// Fetches all tasks for a specific topic
    func fetchTasks(for topic: Topic) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "topic == %@", topic)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    /// Creates a new task under a topic
    @discardableResult
    func createTask(title: String, notes: String? = nil, isDone: Bool = false, deadline: Date? = nil, topic: Topic) -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        task.notes = notes
        task.isDone = isDone
        task.deadline = deadline
        task.topic = topic
        saveContext()
        return task
    }

    /// Convenience overload supporting (topic: ..., deadline: ...) argument order
    @discardableResult
    func createTask(title: String, notes: String? = nil, isDone: Bool = false, topic: Topic, deadline: Date? = nil) -> Task {
        return createTask(title: title, notes: notes, isDone: isDone, deadline: deadline, topic: topic)
    }
    
    /// Updates an existing task
    func updateTask(_ task: Task, title: String, notes: String? = nil, isDone: Bool = false, deadline: Date? = nil) {
        task.title = title
        task.notes = notes
        task.isDone = isDone
        if let deadline = deadline {
            task.deadline = deadline
        }
        saveContext()
    }
    
    /// Toggles task completion state
    func toggleTaskDone(_ task: Task) {
        task.isDone.toggle()
        saveContext()
    }
    
    /// Deletes a task
    func deleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    // MARK: - Study Schedule & Timeframe Filtering
    
    /// Fetches tasks organized by time horizon (Today, Tomorrow, Weekly, Monthly, All)
    func fetchTasks(for timeframe: StudyTimeframe) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isDone == NO")
        
        guard let allPending = try? context.fetch(request) else { return [] }
        let calendar = Calendar.current
        let now = Date()
        
        let filtered = allPending.filter { task -> Bool in
            guard let deadline = task.deadline else {
                // If no specific deadline is set, include in "Today" and "All" so the student never misses it
                return timeframe == .today || timeframe == .all || timeframe == .thisWeek
            }
            
            switch timeframe {
            case .today:
                // Due today or overdue
                return calendar.isDateInToday(deadline) || deadline < now
                
            case .tomorrow:
                return calendar.isDateInTomorrow(deadline)
                
            case .thisWeek:
                // Within 7 days
                let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now
                return deadline >= now && deadline <= weekFromNow
                
            case .thisMonth:
                // Within 30 days
                let monthFromNow = calendar.date(byAdding: .day, value: 30, to: now) ?? now
                return deadline >= now && deadline <= monthFromNow
                
            case .all:
                return true
            }
        }
        
        // Sort by deadline (soonest first)
        return filtered.sorted { (t1, t2) -> Bool in
            let d1 = t1.deadline ?? Date.distantFuture
            let d2 = t2.deadline ?? Date.distantFuture
            return d1 < d2
        }
    }
    
    /// Fetches all pending (incomplete) tasks across all courses/topics for Today view
    func fetchTodayPendingTasks() -> [Task] {
        return fetchTasks(for: .today)
    }
    
    // MARK: - AI Summary Operations
    
    /// Saves or updates the AI summary for a topic (One-to-One relationship)
    func saveAISummary(content: String, for topic: Topic) {
        if let existing = topic.aiSummary {
            existing.content = content
            existing.generatedAt = Date()
        } else {
            let summary = AISummary(context: context)
            summary.id = UUID()
            summary.content = content
            summary.generatedAt = Date()
            summary.topic = topic
        }
        saveContext()
    }
    
    // MARK: - Deep Statistics & Course Mastery Insights
    
    /// Calculates progress for a course (completed tasks / total tasks)
    func getCourseProgress(course: Course) -> (totalTasks: Int, completedTasks: Int, progress: Float) {
        guard let topics = course.topics as? Set<Topic>, !topics.isEmpty else {
            return (0, 0, 0.0)
        }
        var total = 0
        var completed = 0
        for topic in topics {
            if let tasks = topic.tasks as? Set<Task> {
                total += tasks.count
                completed += tasks.filter { $0.isDone }.count
            }
        }
        let progress = total > 0 ? Float(completed) / Float(total) : 0.0
        return (total, completed, progress)
    }
    
    /// Calculates progress for a specific topic
    func getTopicProgress(topic: Topic) -> (totalTasks: Int, completedTasks: Int, progress: Float) {
        guard let tasks = topic.tasks as? Set<Task>, !tasks.isEmpty else {
            return (0, 0, 0.0)
        }
        let total = tasks.count
        let completed = tasks.filter { $0.isDone }.count
        let progress = total > 0 ? Float(completed) / Float(total) : 0.0
        return (total, completed, progress)
    }
    
    /// Returns deep subject mastery insights for each enrolled course (Used in Analytics tab)
    func getCourseMasteryInsights() -> [CourseMasteryInsight] {
        let courses = fetchCourses()
        var insights: [CourseMasteryInsight] = []
        
        for course in courses {
            let topics = (course.topics as? Set<Topic>) ?? []
            var totalTasks = 0
            var completedTasks = 0
            var aiSummariesCount = 0
            
            for topic in topics {
                if topic.aiSummary != nil {
                    aiSummariesCount += 1
                }
                if let tasks = topic.tasks as? Set<Task> {
                    totalTasks += tasks.count
                    completedTasks += tasks.filter { $0.isDone }.count
                }
            }
            
            let progress = totalTasks > 0 ? Float(completedTasks) / Float(totalTasks) : 0.0
            
            let insight = CourseMasteryInsight(
                course: course,
                totalLessons: totalTasks,
                completedLessons: completedTasks,
                progress: progress,
                moduleCount: topics.count,
                colorTag: course.colorTag ?? "Purple",
                aiSummaryCount: aiSummariesCount
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    /// Calculates overall application statistics for Stats Screen
    func getAppStats() -> (totalCourses: Int, totalTopics: Int, totalTasks: Int, completedTasks: Int, completionRate: Double) {
        let courses = fetchCourses()
        let coursesCount = courses.count
        
        var topicsCount = 0
        var tasksCount = 0
        var completedTasksCount = 0
        
        for course in courses {
            if let topics = course.topics as? Set<Topic> {
                topicsCount += topics.count
                for topic in topics {
                    if let tasks = topic.tasks as? Set<Task> {
                        tasksCount += tasks.count
                        completedTasksCount += tasks.filter { $0.isDone }.count
                    }
                }
            }
        }
        
        let rate = tasksCount > 0 ? (Double(completedTasksCount) / Double(tasksCount)) * 100.0 : 0.0
        return (coursesCount, topicsCount, tasksCount, completedTasksCount, rate)
    }
    
    // MARK: - Comprehensive Curriculum Seeder
    
    private func multiPageNotes(_ pages: [String]) -> String {
        return pages.joined(separator: "\n\n--- [STUDYMATE_PAGE_BREAK] ---\n\n")
    }

    func createSampleDataIfEmpty() {
        seedComprehensiveCurriculum(force: false)
    }

    func seedComprehensiveCurriculum(force: Bool = false) {
        if !force && !fetchCourses().isEmpty { return }
        
        print("🌱 Seeding Comprehensive Multi-Page Curriculum for StudyMate AI...")
        let calendar = Calendar.current
        let now = Date()

        // =========================================================================
        // COURSE 1: Swift Programming & Architecture
        // =========================================================================
        let swiftCourse = createCourse(name: "Swift Programming & Architecture", colorTag: "Purple")

        // Module 1: Swift Basics & Fundamentals
        let m1 = createTopic(title: "Swift Basics & Fundamentals", deadline: calendar.date(byAdding: .day, value: 1, to: now), course: swiftCourse)
        
        createTask(
            title: "Type Safety, Optionals & Nil-Coalescing",
            notes: multiPageNotes([
                """
                # Page 1: Type Safety & The Optional Paradigm

                Swift is a strongly-typed and type-safe language. The compiler guarantees that variables can never contain an uninitialized state or an unexpected type.

                ## What is an Optional?
                Under the hood, Swift Optionals are implemented as an enum:
                ```swift
                enum Optional<Wrapped> {
                    case none
                    case some(Wrapped)
                }
                ```

                ## Declaration Syntax:
                ```swift
                var username: String? = "Rajat"
                var score: Int? = nil // Valid: Contains no value
                ```

                > **Key Takeaway:** You cannot use an optional directly where a non-optional value is expected. You must safely unwrap it first!
                """,
                """
                # Page 2: Safe Unwrapping Patterns

                Never force-unwrap (`!`) in production code without a mathematically proven precondition. Instead, use these idiomatic unwrapping techniques:

                ## 1. Optional Binding (`if let` & `guard let`)
                ```swift
                func greetUser(name: String?) {
                    // Early exit pattern keeps nesting shallow:
                    guard let validName = name, !validName.isEmpty else {
                        print("Welcome, Guest!")
                        return
                    }
                    print("Welcome back, \\(validName)!")
                }
                ```

                ## 2. Optional Chaining
                Allows querying nested properties without manual nested `if let`:
                ```swift
                let avatarURL = user?.profile?.avatar?.absoluteString
                ```
                If any link in the chain is `nil`, the entire expression evaluates cleanly to `nil`.
                """,
                """
                # Page 3: Nil-Coalescing & Defensive Programming

                ## The Nil-Coalescing Operator (`??`)
                Provides a sensible fallback value if the optional evaluates to `nil`:
                ```swift
                let serverPort = config.customPort ?? 8080
                let greeting = user.nickname ?? user.fullName ?? "Student"
                ```

                ## Implicitly Unwrapped Optionals (`Type!`)
                Use only when a property is guaranteed to be set immediately after initialization (e.g., `@IBOutlet` connections or complex two-phase initializers):
                ```swift
                @IBOutlet weak var titleLabel: UILabel!
                ```

                ## Best Practices Summary:
                1. Prefer `guard let` to avoid the "Pyramid of Doom".
                2. Avoid force-unwrapping (`!`) unless writing unit tests or accessing bundle resources known at compile-time.
                3. Leverage `??` for concise default fallbacks.
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 1, to: now),
            topic: m1
        )

        createTask(
            title: "Control Flow, Pattern Matching & Switch",
            notes: multiPageNotes([
                """
                # Page 1: Control Flow & Loops

                Swift provides fast and ergonomic control flow structures:

                ## For-In Iteration:
                ```swift
                let primes = [2, 3, 5, 7, 11, 13]
                for (index, prime) in primes.enumerated() {
                    print("Prime #\\(index + 1): \\(prime)")
                }

                // Range iteration with stride:
                for minute in stride(from: 0, to: 60, by: 15) {
                    print("Quarter mark: \\(minute)")
                }
                ```

                ## While & Repeat-While:
                ```swift
                var attempts = 3
                repeat {
                    attempts -= 1
                } while attempts > 0
                ```
                """,
                """
                # Page 2: Advanced Pattern Matching with Switch

                In Swift, `switch` statements must be exhaustive and do not fall through automatically.

                ## Pattern Matching with Tuples & `where`:
                ```swift
                let point = (x: 10, y: 0)

                switch point {
                case (0, 0):
                    print("Origin")
                case (_, 0):
                    print("On the X axis at \\(point.x)")
                case (0, _):
                    print("On the Y axis at \\(point.y)")
                case let (x, y) where x == y:
                    print("On the diagonal x == y")
                case let (x, y):
                    print("Point at (\\(x), \\(y))")
                }
                ```
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 2, to: now),
            topic: m1
        )

        createTask(
            title: "Functions, In-Out Parameters & Return Tuples",
            notes: multiPageNotes([
                """
                # Page 1: Function Signatures & Argument Labels

                Functions in Swift are first-class citizens. You can pass them as arguments, return them from other functions, and assign them to variables.

                ## Argument Labels & Parameter Names:
                ```swift
                func scheduleSession(for student: String, at time: Date) -> Bool {
                    print("Scheduled \\(student) at \\(time)")
                    return true
                }

                // Call site reads like natural English:
                scheduleSession(for: "Alice", at: Date())
                ```

                Omitting argument labels with `_`:
                ```swift
                func square(_ value: Double) -> Double {
                    return value * value
                }
                ```
                """,
                """
                # Page 2: In-Out Parameters (`inout`)

                Function parameters are constants (`let`) by default. To modify an argument and have the modification persist outside the function, mark it `inout`:

                ```swift
                func swapValues<T>(_ a: inout T, _ b: inout T) {
                    let temp = a
                    a = b
                    b = temp
                }

                var x = 10
                var y = 20
                swapValues(&x, &y) // Must pass memory address with '&'
                print("x: \\(x), y: \\(y)") // x: 20, y: 10
                ```

                > **Note:** In-out parameters use Copy-In Copy-Out semantics. The value is copied in on call and copied back out upon return.
                """,
                """
                # Page 3: Variadic Arguments & Multiple Return Values

                ## Variadic Parameters:
                Accepts zero or more values of a specified type:
                ```swift
                func calculateAverage(_ scores: Double...) -> Double {
                    guard !scores.isEmpty else { return 0 }
                    let sum = scores.reduce(0, +)
                    return sum / Double(scores.count)
                }
                let avg = calculateAverage(95.5, 88.0, 92.5, 99.0)
                ```

                ## Returning Named Tuples:
                ```swift
                func minMax(array: [Int]) -> (min: Int, max: Int)? {
                    guard let first = array.first else { return nil }
                    var curMin = first, curMax = first
                    for val in array[1...] {
                        if val < curMin { curMin = val }
                        if val > curMax { curMax = val }
                    }
                    return (min: curMin, max: curMax)
                }
                ```
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 3, to: now),
            topic: m1
        )

        // Module 2: Intermediate Swift & OOP
        let m2 = createTopic(title: "Intermediate Swift & Memory Management", deadline: calendar.date(byAdding: .day, value: 5, to: now), course: swiftCourse)
        
        createTask(
            title: "Structs vs Classes & Value Semantics",
            notes: multiPageNotes([
                """
                # Page 1: Value vs Reference Types

                The fundamental architectural decision in Swift is choosing between `struct` (Value Type) and `class` (Reference Type).

                | Feature | Struct | Class |
                | :--- | :--- | :--- |
                | **Storage** | Stack allocated (Fast) | Heap allocated (Metadata overhead) |
                | **Copying** | Deep copy by value | Reference pointer copied |
                | **Inheritance** | None (Use Protocols) | Single inheritance supported |
                | **Deinitializer**| No `deinit` | Has `deinit` method |
                | **Thread Safety**| Thread-safe by default | Requires synchronization |
                """,
                """
                # Page 2: Mutating Methods & Memberwise Init

                ## Mutating Methods:
                Because structs are value types, their properties cannot be modified from within instance methods by default. Mark methods that alter state as `mutating`:
                ```swift
                struct BankAccount {
                    private(set) var balance: Double = 0.0

                    mutating func deposit(amount: Double) {
                        guard amount > 0 else { return }
                        balance += amount
                    }
                }
                ```

                ## Automatic Memberwise Initializers:
                Structs receive a free initializer covering all properties. Classes do not and require explicit `init` implementations.
                """,
                """
                # Page 3: Automatic Reference Counting (ARC)

                Classes participate in ARC. The runtime tracks reference counts to determine when to deallocate memory:

                ## Strong Reference Cycles:
                When two objects hold strong references to each other, neither count ever drops to 0, resulting in a **Memory Leak**.

                ```swift
                class Teacher {
                    var student: Student?
                    deinit { print("Teacher deallocated") }
                }

                class Student {
                    weak var teacher: Teacher? // 'weak' breaks the retain cycle!
                    deinit { print("Student deallocated") }
                }
                ```

                - `weak`: Always optional (`Teacher?`), zeroed out automatically when target deallocates.
                - `unowned`: Non-optional, used when lifetime of target is guaranteed to outlive caller.
                """,
                """
                # Page 4: Copy-On-Write (CoW) & Decision Framework

                ## Copy-On-Write Optimization:
                Standard library collections (`Array`, `Dictionary`, `Set`, `String`) are structs with internal reference storage. They only perform an expensive memory copy when an instance is actually modified!

                ## When to choose Struct:
                - Representing standalone data models (e.g. `User`, `Task`, `Lesson`).
                - Entity identity is determined by its values.
                - Concurrency safety without locks.

                ## When to choose Class:
                - Managing shared mutable state (e.g. `CoreDataManager`, `AudioPlayer`).
                - Subclassing UIKit components (`UIViewController`, `UITableViewCell`).
                - Resource lifecycle cleanup required in `deinit`.
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 4, to: now),
            topic: m2
        )

        createTask(
            title: "Closures, Escaping & Retain Cycles",
            notes: multiPageNotes([
                """
                # Page 1: Closure Syntax & Shorthand Expressions

                Closures are self-contained blocks of functionality that can be passed around and executed.

                ## Basic Closure Syntax:
                ```swift
                let multiplier: (Int, Int) -> Int = { (a: Int, b: Int) in
                    return a * b
                }
                ```

                ## Shorthand Argument Names & Trailing Closures:
                ```swift
                let numbers = [5, 2, 8, 1, 9]
                let sorted = numbers.sorted { $0 < $1 }
                let doubled = numbers.map { $0 * 2 }
                let evens = numbers.filter { $0 % 2 == 0 }
                ```
                """,
                """
                # Page 2: Non-Escaping vs Escaping Closures (`@escaping`)

                By default, closure parameters are non-escaping: they execute synchronously within the function's scope before returning.

                ## Escaping Closures:
                Mark with `@escaping` when the closure is stored in a property or executed asynchronously after the function returns:
                ```swift
                class NetworkService {
                    var completionHandler: ((Data?) -> Void)?

                    func fetchData(completion: @escaping (Data?) -> Void) {
                        DispatchQueue.global().async {
                            // Work happens in background...
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    }
                }
                ```
                """,
                """
                # Page 3: Capture Lists & Retain Cycle Prevention

                When an `@escaping` closure references `self`, it increments `self`'s reference count. If `self` also owns the closure, a retain cycle occurs!

                ## The Capture List Solution:
                ```swift
                class ProfileViewModel {
                    var onUpdate: (() -> Void)?

                    func startListening() {
                        networkService.fetchData { [weak self] data in
                            guard let self = self else { return }
                            self.applyData(data)
                        }
                    }

                    private func applyData(_ data: Data?) {
                        // Safe: No retain cycle
                    }
                }
                ```
                Always use `[weak self]` in network callbacks, notification listeners, and timer blocks!
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 5, to: now),
            topic: m2
        )

        // Module 3: Advanced Swift & Concurrency
        let m3 = createTopic(title: "Advanced Swift & Modern Concurrency", deadline: calendar.date(byAdding: .day, value: 8, to: now), course: swiftCourse)
        
        createTask(
            title: "Async/Await, Tasks & Actors",
            notes: multiPageNotes([
                """
                # Page 1: The Modern Concurrency Model

                Swift 5.5+ replaced nested completion handlers with structured `async/await`.

                ## The Problem with Callbacks:
                - Callback hell and nested indentation.
                - Easy to forget calling `completion()` in error paths.
                - Complex thread synchronization.

                ## Async Syntax:
                ```swift
                func fetchUserProfile(id: String) async throws -> UserProfile {
                    let url = URL(string: "https://api.example.com/users/\\(id)")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    return try JSONDecoder().decode(UserProfile.self, from: data)
                }
                ```
                The `await` keyword marks a potential suspension point where the thread can yield to other work.
                """,
                """
                # Page 2: Spawning Tasks & Structured Concurrency

                ## Creating a Task:
                To call an `async` function from a synchronous context (e.g. a button tap):
                ```swift
                @objc private func refreshTapped() {
                    Task {
                        do {
                            let profile = try await fetchUserProfile(id: "123")
                            updateUI(with: profile)
                        } catch {
                            showError(error)
                        }
                    }
                }
                ```

                ## Parallel Execution with `async let`:
                ```swift
                async let avatar = downloadAvatar()
                async let stats = fetchStats()

                // Both download concurrently in parallel!
                let (userAvatar, userStats) = try await (avatar, stats)
                ```
                """,
                """
                # Page 3: Task Groups for Dynamic Batches

                When downloading an arbitrary number of items concurrently, use `withTaskGroup`:

                ```swift
                func downloadAllLessons(ids: [String]) async throws -> [Lesson] {
                    try await withThrowingTaskGroup(of: Lesson.self) { group in
                        for id in ids {
                            group.addTask {
                                try await fetchLesson(id: id)
                            }
                        }

                        var results: [Lesson] = []
                        for try await lesson in group {
                            results.append(lesson)
                        }
                        return results
                    }
                }
                ```
                """,
                """
                # Page 4: Actors & Data Race Prevention

                An `actor` is a reference type that isolates its state, guaranteeing synchronized access without manual locks or dispatch queues.

                ```swift
                actor StudyTracker {
                    private var completedCount: Int = 0

                    func recordCompletion() {
                        completedCount += 1
                    }

                    func getCount() -> Int {
                        return completedCount
                    }
                }

                // Callers must 'await' across actor isolation boundaries:
                let count = await tracker.getCount()
                ```
                The compiler mathematically prevents data races at compile time!
                """,
                """
                # Page 5: `@MainActor` & Cooperative Cancellation

                ## `@MainActor`:
                Ensures UI updates always run on the Main Thread:
                ```swift
                @MainActor
                class LessonsViewModel: ObservableObject {
                    @Published var lessons: [Lesson] = []

                    func load() async {
                        let data = try? await network.fetch()
                        self.lessons = data ?? [] // Guaranteed on main thread!
                    }
                }
                ```

                ## Cooperative Cancellation:
                Tasks can be cancelled. Functions should inspect `Task.isCancelled`:
                ```swift
                for step in steps {
                    try Task.checkCancellation()
                    await processStep(step)
                }
                ```
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 7, to: now),
            topic: m3
        )

        // =========================================================================
        // COURSE 2: iOS Development with UIKit
        // =========================================================================
        let uikitCourse = createCourse(name: "iOS Development with UIKit", colorTag: "Blue")

        let uikitM1 = createTopic(title: "App Lifecycle & Architecture", deadline: calendar.date(byAdding: .day, value: 3, to: now), course: uikitCourse)
        
        createTask(
            title: "AppDelegate vs SceneDelegate & State Transitions",
            notes: multiPageNotes([
                """
                # Page 1: AppDelegate vs SceneDelegate Roles

                Since iOS 13, Apple split application lifecycle management:

                ## AppDelegate:
                Manages process-level lifecycle events:
                - `application(_:didFinishLaunchingWithOptions:)`: Process launch point.
                - Push notification device token registration.
                - Session lifecycle creation (`configurationForConnecting`).

                ## SceneDelegate:
                Manages multi-window UI scenes:
                - Holds the root `UIWindow` reference.
                - Manages active, inactive, background, and foreground states for each window.
                """,
                """
                # Page 2: Scene Lifecycle State Machine

                Each scene transitions through well-defined states:

                1. **Unattached**: Scene is not connected to UI.
                2. **Foreground Inactive**: Running in foreground but not receiving touch events (e.g. system alert, Siri active).
                3. **Foreground Active**: Interactive and receiving touch events (`sceneDidBecomeActive`).
                4. **Background**: Running in background; app screenshot taken (`sceneDidEnterBackground`).
                5. **Suspended**: In memory but executing 0 CPU instructions.
                """,
                """
                # Page 3: Handling State Transitions & Persistence

                Save critical state when entering the background:

                ```swift
                func sceneDidEnterBackground(_ scene: UIScene) {
                    // Save Core Data context immediately:
                    CoreDataManager.shared.saveContext()
                    // Flush analytics caches or cancel pending network sessions
                }
                ```

                > **Tip:** Do not perform heavy synchronous file I/O in `sceneDidEnterBackground`, as the OS will terminate the app if execution takes longer than ~5 seconds.
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 2, to: now),
            topic: uikitM1
        )

        createTask(
            title: "UIViewController Lifecycle Deep-Dive",
            notes: multiPageNotes([
                """
                # Page 1: Creation & Loading Phases

                1. `init(nibName:bundle:)` / `init(coder:)`:
                   Object allocation. Set up fundamental non-UI state here.

                2. `loadView()`:
                   Creates the root `view`. Do NOT call `super.loadView()` if providing a custom programmatic view:
                   ```swift
                   override func loadView() {
                       view = CustomDashboardView()
                   }
                   ```

                3. `viewDidLoad()`:
                   Called once when `view` is loaded into RAM. Configure subviews, layout constraints, and register table cells here.
                """,
                """
                # Page 2: Appearance & Layout Passes

                ## `viewWillAppear(_ animated: Bool)`:
                Called right before the view becomes visible. Ideal for:
                - Refreshing data from Core Data.
                - Reloading table views.
                - Showing or hiding navigation bars.

                ## Layout Passes:
                - `viewWillLayoutSubviews()`: Auto Layout engine is about to calculate frames.
                - `viewDidLayoutSubviews()`: Subview bounds are final. Perfect place to update custom layer frames (such as `CAGradientLayer`).
                """,
                """
                # Page 3: Visibility & Dismissal Phases

                ## `viewDidAppear(_ animated: Bool)`:
                View is now physically on screen.
                - Start animations.
                - Begin video playback.
                - Request location permissions.

                ## `viewWillDisappear` & `viewDidDisappear`:
                - Tear down observers, pause timers, stop audio.
                - Save drafts if editing.
                """,
                """
                # Page 4: Destruction & Deallocation

                ## `deinit`:
                Always verify that view controllers deallocate when popped from navigation stacks:
                ```swift
                deinit {
                    print("✅ \\(Self.self) deallocated safely")
                }
                ```
                If `deinit` is not called, check for retain cycles in closures, delegates (did you declare `weak var delegate: ...`?), or `NotificationCenter` observers!
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 3, to: now),
            topic: uikitM1
        )

        let uikitM2 = createTopic(title: "Views, Controls & Navigation", deadline: calendar.date(byAdding: .day, value: 6, to: now), course: uikitCourse)
        
        createTask(
            title: "UITableView & Cell Reuse Mechanics",
            notes: multiPageNotes([
                """
                # Page 1: Why Cell Reuse Matters

                If a table has 10,000 items, allocating 10,000 `UITableViewCell` instances would instantly crash the device due to out-of-memory (OOM) errors.

                ## The Flywheel Concept:
                UIKit creates only enough cells to fill the visible screen height + 2 buffer cells (approx. 10–12 cells). As a cell scrolls off the top, it enters the **Reuse Queue**. When a new row scrolls in from the bottom, UIKit reclaims that queued cell!
                """,
                """
                # Page 2: Registering & Dequeuing Cells

                ## Registration in `viewDidLoad`:
                ```swift
                tableView.register(LessonCell.self, forCellReuseIdentifier: "LessonCell")
                ```

                ## Dequeuing in `cellForRowAt`:
                ```swift
                func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as? LessonCell else {
                        return UITableViewCell()
                    }
                    cell.configure(with: lessons[indexPath.row])
                    return cell
                }
                ```
                """,
                """
                # Page 3: Self-Sizing Cells with Auto Layout

                To make cells calculate dynamic heights based on text length:

                1. Set table properties:
                ```swift
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 96
                ```

                2. Establish an unbroken vertical Auto Layout chain from `contentView.topAnchor` to `contentView.bottomAnchor`:
                ```swift
                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                    bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                    bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
                ])
                ```
                """,
                """
                # Page 4: The Crucial `prepareForReuse()`

                Because cells are recycled, stale data can flicker on screen if not reset:

                ```swift
                override func prepareForReuse() {
                    super.prepareForReuse()
                    titleLabel.text = nil
                    thumbnailImageView.image = nil
                    imageDownloadTask?.cancel() // Cancel inflight image download!
                    accentBar.backgroundColor = .clear
                }
                ```
                """,
                """
                # Page 5: Contextual Swipe Actions

                Modern swipe actions for mark-done and delete:

                ```swift
                func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                    let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
                        self.deleteItem(at: indexPath)
                        done(true)
                    }
                    delete.image = UIImage(systemName: "trash.fill")
                    return UISwipeActionsConfiguration(actions: [delete])
                }
                ```
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 5, to: now),
            topic: uikitM2
        )

        // =========================================================================
        // COURSE 3: Auto Layout & Responsive Design
        // =========================================================================
        let autoLayoutCourse = createCourse(name: "Auto Layout & Responsive Design", colorTag: "Teal")

        let alM1 = createTopic(title: "Constraints & Safe Area Mastery", deadline: calendar.date(byAdding: .day, value: 4, to: now), course: autoLayoutCourse)
        
        createTask(
            title: "NSLayoutConstraint vs Layout Anchors",
            notes: multiPageNotes([
                """
                # Page 1: The Auto Layout Equation

                Every constraint in Auto Layout represents a linear equation:
                ```
                view1.attribute = multiplier * view2.attribute + constant
                ```

                ## Modern Layout Anchors:
                Type-safe API preventing illegal combinations (e.g. constraining a `leadingAnchor` to a `topAnchor` won't compile!):
                ```swift
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
                ```
                """,
                """
                # Page 2: Programmatic Setup Rules

                Before activating constraints on a view, you **MUST** disable `autoresizingMask`:

                ```swift
                let customCard = UIView()
                customCard.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(customCard) // Must add as subview BEFORE constraining!
                ```

                ## Batch Activation:
                Always activate constraints in batches rather than setting `isActive = true` individually to optimize engine performance:
                ```swift
                NSLayoutConstraint.activate([
                    customCard.topAnchor.constraint(equalTo: view.topAnchor),
                    customCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    customCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    customCard.heightAnchor.constraint(equalToConstant: 120)
                ])
                ```
                """,
                """
                # Page 3: Safe Area Layout Guide

                Device screens have physical cutouts (Notch, Dynamic Island, Home Bar, Rounded Edges).

                ## Pinning to Safe Area:
                ```swift
                NSLayoutConstraint.activate([
                    header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                ])
                ```
                In landscape orientation, `safeAreaLayoutGuide` automatically expands horizontal margins by 47–59pt to keep text clear of the camera island!
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 3, to: now),
            topic: alM1
        )

        createTask(
            title: "Intrinsic Content Size & Priority Tuning",
            notes: multiPageNotes([
                """
                # Page 1: What is Intrinsic Content Size?

                Some views know their natural size based on their content:
                - `UILabel`: Fits its text string and font.
                - `UIButton`: Fits its title and padding.
                - `UIImageView`: Fits the underlying `UIImage` dimensions.
                - Plain `UIView`: Has no intrinsic size by default (size is 0x0 unless constrained).
                """,
                """
                # Page 2: Content Hugging Priority (Resisting Stretching)

                Determines how aggressively a view resists being made larger than its intrinsic content size:

                ```swift
                // High Hugging: "Keep me as compact as my text!"
                badgeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

                // Low Hugging: "Feel free to stretch me to fill remaining space!"
                titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                ```
                """,
                """
                # Page 3: Content Compression Resistance (Resisting Clipping)

                Determines how aggressively a view resists being squished smaller than its content:

                ```swift
                // Required Resistance: "Under NO circumstance truncate my text!"
                dateBadge.setContentCompressionResistancePriority(.required, for: .horizontal)

                // Low Resistance: "If screen is narrow, truncate me with '...' first"
                descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                ```
                """,
                """
                # Page 4: Resolving Conflicts & Ambiguities

                Priority levels in UIKit:
                - `.required` = 1000
                - `.defaultHigh` = 750
                - `.defaultLow` = 250

                > **Golden Rule:** When placing two labels horizontally in a row, ALWAYS set one with lower hugging priority (to expand) and one with higher compression resistance (to prevent truncation)!
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 4, to: now),
            topic: alM1
        )

        // =========================================================================
        // COURSE 4: Core Data & Persistent Storage
        // =========================================================================
        let coreDataCourse = createCourse(name: "Core Data & Persistent Storage", colorTag: "Emerald")

        let cdM1 = createTopic(title: "Core Data Architecture & CRUD", deadline: calendar.date(byAdding: .day, value: 5, to: now), course: coreDataCourse)
        
        createTask(
            title: "NSPersistentContainer & The Core Data Stack",
            notes: multiPageNotes([
                """
                # Page 1: The Core Data Stack Architecture

                Core Data is an object graph manager and persistence framework, not merely a SQL wrapper.

                ## The Core Components:
                1. **NSManagedObjectModel**: The `.xcdatamodeld` schema definition file.
                2. **NSPersistentStoreCoordinator**: Bridges the in-memory object model to the physical SQLite database on disk.
                3. **NSManagedObjectContext**: The in-memory scratchpad where managed objects (`Course`, `Topic`, `Task`) are created, edited, and queried.
                4. **NSPersistentContainer**: The modern orchestrator that encapsulates all 3 above components.
                """,
                """
                # Page 2: Threading & Context Concurrency Rules

                ## Main Context (`viewContext`):
                Tied directly to the Main Thread. Must be used for all UI data source bindings:
                ```swift
                let context = persistentContainer.viewContext
                ```

                ## Background Tasks:
                Never access or pass `NSManagedObject` instances across different threads! Instead, use `performBackgroundTask`:
                ```swift
                persistentContainer.performBackgroundTask { bgContext in
                    // Safe to parse 10,000 JSON records here without freezing UI!
                    try? bgContext.save()
                }
                ```
                """,
                """
                # Page 3: Safe Context Saving Pattern

                Always check `context.hasChanges` before writing to disk:

                ```swift
                func saveContext() {
                    guard context.hasChanges else { return }
                    do {
                        try context.save()
                    } catch {
                        context.rollback()
                        print("Core Data Save Error: \\(error.localizedDescription)")
                    }
                }
                ```
                """
            ]),
            isDone: true,
            deadline: calendar.date(byAdding: .day, value: 4, to: now),
            topic: cdM1
        )

        createTask(
            title: "Entity Relationships & Delete Rules",
            notes: multiPageNotes([
                """
                # Page 1: Designing Relationships

                In StudyMate AI, our schema links courses to modules and lessons:
                - `Course` (1) ──── (Many) `Topic`
                - `Topic` (1) ──── (Many) `Task`
                - `Topic` (1) ──── (1) `AISummary`

                Always configure **Inverse Relationships** so Core Data can maintain bidirectional object graph consistency!
                """,
                """
                # Page 2: The 4 Delete Rules

                When an entity is deleted, its delete rule dictates what happens to related entities:

                1. **Cascade**: Deleting a `Course` automatically deletes all child `Topics` and their `Tasks`.
                2. **Nullify**: Deleting a `Topic` sets `task.topic = nil`.
                3. **Deny**: Prevents deleting a `Course` if it still has active `Topics`.
                4. **No Action**: Does nothing (dangerous; causes orphaned pointers).

                > **Best Practice:** Use `Cascade` for parent-child hierarchies to keep the database free of orphaned records!
                """,
                """
                # Page 3: Complex Predicates & Sorting

                Querying with `NSPredicate`:
                ```swift
                let request: NSFetchRequest<Task> = Task.fetchRequest()

                // Filter for pending tasks matching search query:
                request.predicate = NSPredicate(
                    format: "isDone == NO AND title CONTAINS[cd] %@", searchText
                )

                // Sort soonest deadline first:
                request.sortDescriptors = [
                    NSSortDescriptor(key: "deadline", ascending: true)
                ]

                let results = try? context.fetch(request)
                ```
                `[cd]` enables case-insensitive and diacritic-insensitive matching.
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 6, to: now),
            topic: cdM1
        )

        // =========================================================================
        // COURSE 5: URLSession & REST API Networking
        // =========================================================================
        let networkingCourse = createCourse(name: "URLSession & REST Networking", colorTag: "Coral")

        let netM1 = createTopic(title: "Requests, Codable & Network Architecture", deadline: calendar.date(byAdding: .day, value: 7, to: now), course: networkingCourse)
        
        createTask(
            title: "URLSession Configuration & Async Requests",
            notes: multiPageNotes([
                """
                # Page 1: URLSession Configuration Types

                1. `URLSessionConfiguration.default`: Uses persistent disk caches and stored credentials.
                2. `URLSessionConfiguration.ephemeral`: In-memory only; no cookies, caches, or credentials saved (like incognito mode).
                3. `URLSessionConfiguration.background(withIdentifier:)`: Allows downloads and uploads to continue even if app is suspended or terminated by OS.
                """,
                """
                # Page 2: Modern Async/Await Networking

                ```swift
                func fetchCurriculum() async throws -> [CourseDTO] {
                    guard let url = URL(string: "https://api.studymate.ai/v1/courses") else {
                        throw APIError.invalidURL
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")

                    let (data, response) = try await URLSession.shared.data(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }

                    return try JSONDecoder().decode([CourseDTO].self, from: data)
                }
                ```
                """,
                """
                # Page 3: Swift Codable Mastery

                ## Custom CodingKeys:
                Transform server `snake_case` to Swift `camelCase`:
                ```swift
                struct CourseDTO: Codable {
                    let id: String
                    let courseTitle: String
                    let totalLessons: Int

                    enum CodingKeys: String, CodingKey {
                        case id
                        case courseTitle = "course_title"
                        case totalLessons = "total_lessons"
                    }
                }
                ```

                Or use the automatic strategy:
                ```swift
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                ```
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 6, to: now),
            topic: netM1
        )

        createTask(
            title: "Error Handling & Generic Network Manager",
            notes: multiPageNotes([
                """
                # Page 1: Typed API Error Enums

                ```swift
                enum APIError: LocalizedError {
                    case invalidURL
                    case invalidResponse
                    case serverError(statusCode: Int)
                    case decodingFailed(underlying: Error)
                    case networkUnavailable

                    var errorDescription: String? {
                        switch self {
                        case .invalidURL: return "Invalid server endpoint URL."
                        case .invalidResponse: return "Received an invalid server response."
                        case .serverError(let code): return "Server returned error code \\(code)."
                        case .decodingFailed: return "Failed to parse server data."
                        case .networkUnavailable: return "No internet connection detected."
                        }
                    }
                }
                ```
                """,
                """
                # Page 2: Protocol-Oriented Generic Network Client

                ```swift
                protocol NetworkClientProtocol {
                    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
                }

                class NetworkClient: NetworkClientProtocol {
                    static let shared = NetworkClient()
                    private let session: URLSession

                    init(session: URLSession = .shared) {
                        self.session = session
                    }

                    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
                        let request = endpoint.urlRequest()
                        let (data, response) = try await session.data(for: request)
                        // Validate status code & decode...
                        return try JSONDecoder().decode(T.self, from: data)
                    }
                }
                ```
                """
            ]),
            isDone: false,
            deadline: calendar.date(byAdding: .day, value: 7, to: now),
            topic: netM1
        )

        UserDefaultsManager.shared.hasSeededInitialData = true
        print("✅ Comprehensive Multi-Page Curriculum populated successfully!")
    }
}

