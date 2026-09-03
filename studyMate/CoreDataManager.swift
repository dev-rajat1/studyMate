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
    
    // MARK: - Sample Data Seeder (For Mentor / Testing)
    func createSampleDataIfEmpty() {
        if !fetchCourses().isEmpty { return }
        
        print("🌱 Seeding Sample Data for StudyMate AI...")
        
        // Course 1: iOS Development
        let iosCourse = createCourse(name: "iOS Development with UIKit", colorTag: "Blue")
        let topic1 = createTopic(title: "AutoLayout & Storyboards", deadline: Calendar.current.date(byAdding: .day, value: 2, to: Date()), course: iosCourse)
        createTask(title: "Learn Safe Area Constraints", notes: "Pin elements to safe area layout guide to support notch and dynamic island.", isDone: true, topic: topic1)
        createTask(title: "Master UIStackViews", notes: "Use horizontal and vertical stack views inside custom table view cells.", isDone: false, topic: topic1)
        
        let topic2 = createTopic(title: "CoreData & Relationships", deadline: Calendar.current.date(byAdding: .day, value: 4, to: Date()), course: iosCourse)
        createTask(title: "Create Entities & Attributes", notes: "Course, Topic, Task, AISummary entities.", isDone: true, topic: topic2)
        createTask(title: "Configure Cascade Delete Rules", notes: "When Course is deleted, all its Topics should cascade delete.", isDone: false, topic: topic2)
        
        // Course 2: Data Structures & Algorithms
        let dsaCourse = createCourse(name: "Data Structures & Algorithms", colorTag: "Purple")
        let topic3 = createTopic(title: "Trees & Binary Search Trees", deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date()), course: dsaCourse)
        createTask(title: "Implement Inorder Traversal", notes: "Left -> Root -> Right traversal yields sorted sequence.", isDone: true, topic: topic3)
        createTask(title: "Solve Lowest Common Ancestor (LCA)", notes: "Review recursive and iterative approaches.", isDone: false, topic: topic3)
        
        // Course 3: System Design
        let sysCourse = createCourse(name: "System Design", colorTag: "Emerald")
        let topic4 = createTopic(title: "Caching & Load Balancing", deadline: Calendar.current.date(byAdding: .day, value: 6, to: Date()), course: sysCourse)
        createTask(title: "Compare Redis vs Memcached", notes: "Redis supports persistence and complex data types.", isDone: false, topic: topic4)
        
        UserDefaultsManager.shared.hasSeededInitialData = true
        print("✅ Sample data populated successfully!")
    }
}
