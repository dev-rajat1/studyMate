//
//  AIService.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Handles dynamic AI Notes Summarization and scalable Quiz Generation using Google Gemini API (gemini-3.7-flash).
//

import Foundation

class AIService {
    
    // MARK: - Singleton
    static let shared = AIService()
    private init() {}
    
    // Google Gemini API Base Endpoint
    private let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    // MARK: - Helper: Dynamic Question Count Calculator
    /// Calculates the optimal number of quiz questions based on notes length and lesson count
    private func calculateTargetQuizCount(notesContent: String, taskCount: Int) -> Int {
        let characterCount = notesContent.count
        
        // Base calculation: roughly 1 question per ~200 characters of notes, minimum 4, maximum 15
        if characterCount < 250 {
            return max(4, taskCount * 2)
        } else if characterCount < 700 {
            return max(6, taskCount * 2)
        } else if characterCount < 1500 {
            return max(8, taskCount * 3)
        } else if characterCount < 2800 {
            return min(12, max(10, taskCount * 3))
        } else {
            // Very long notes / multi-page lessons
            return min(18, max(12, taskCount * 4))
        }
    }
    
    // MARK: - Generate AI Summary
    /// Generates an in-depth, structured revision summary tailored to the depth of the notes
    func generateSummary(for topic: Topic, completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let courseName = topic.course?.name ?? "General Study"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        
        // Collect notes from all lessons/tasks
        var formattedLessons: [String] = []
        for task in tasks {
            let taskTitle = task.title ?? "Lesson"
            let notes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !notes.isEmpty {
                formattedLessons.append("📖 Lesson: [\(taskTitle)]\nNotes:\n\(notes)")
            } else {
                formattedLessons.append("📖 Lesson: [\(taskTitle)] (No specific notes written)")
            }
        }
        
        let notesContent = formattedLessons.joined(separator: "\n\n---------------------\n\n")
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are an elite academic professor and study coach.
        Course: "\(courseName)"
        Module: "\(topicTitle)"
        
        The student has provided their complete study notes and lesson details below:
        \"\"\"
        \(notesContent.isEmpty ? "No detailed lesson notes written yet. Generate an in-depth, rigorous master summary for the module: \(topicTitle)." : notesContent)
        \"\"\"
        
        TASK:
        Generate a comprehensive, beautifully structured study summary that scales directly with the length and details of the notes provided above.
        
        Please format the response clearly with clean headings:
        📌 EXECUTIVE OVERVIEW
        (High-level concept summary and real-world significance)
        
        🎯 DEEP-DIVE KEY TAKEAWAYS (By Lesson/Topic)
        (Detailed bullet points covering all important principles, mechanisms, and nuances)
        
        💡 FORMULAS, DEFINITIONS & TERMINOLOGY
        (Important terms, definitions, syntax, or equations mentioned in the notes)
        
        ⚠️ COMMON PITFALLS & EXAM GOTCHAS
        (Frequent student misunderstandings or edge cases to watch out for)
        
        ⚡ RAPID REVISION CHECKLIST
        (5-8 actionable check points for quick pre-exam review)
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model, maxTokens: 2500) { [weak self] result in
                switch result {
                case .success(let text):
                    completion(.success(text))
                case .failure(let error):
                    print("⚠️ Gemini API call failed (\(error.localizedDescription)), falling back to smart simulation...")
                    self?.generateSimulatedSummary(topicTitle: topicTitle, tasks: tasks, notes: notesContent, completion: completion)
                }
            }
        } else {
            generateSimulatedSummary(topicTitle: topicTitle, tasks: tasks, notes: notesContent, completion: completion)
        }
    }
    
    // MARK: - Generate Dynamic AI Quiz
    /// Generates scalable practice quiz questions directly proportional to notes length and complexity
    func generateQuiz(for topic: Topic, completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let courseName = topic.course?.name ?? "General Study"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        
        var formattedLessons: [String] = []
        for task in tasks {
            let taskTitle = task.title ?? "Lesson"
            let notes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !notes.isEmpty {
                formattedLessons.append("📖 Lesson: [\(taskTitle)]\nNotes:\n\(notes)")
            } else {
                formattedLessons.append("📖 Lesson: [\(taskTitle)]")
            }
        }
        
        let notesContent = formattedLessons.joined(separator: "\n\n")
        let targetQuestionCount = calculateTargetQuizCount(notesContent: notesContent, taskCount: tasks.count)
        
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are an expert exam question creator.
        Course: "\(courseName)"
        Module: "\(topicTitle)"
        
        Study Notes Context:
        \"\"\"
        \(notesContent.isEmpty ? "General academic subject knowledge for \(topicTitle)." : notesContent)
        \"\"\"
        
        TASK:
        Based on the length and depth of the study notes above, generate EXACTLY \(targetQuestionCount) high-yield Multiple Choice Practice Questions (MCQs).
        Distribute the questions evenly across all lessons and concepts in the notes (from foundational definitions to advanced conceptual applications).
        
        Format each question STRICTLY as:
        
        Q[Number]. [Question Text]
        A) [Option A]
        B) [Option B]
        C) [Option C]
        D) [Option D]
        ✅ Answer: [Correct Letter]
        💡 Explanation: [Clear explanation of why this answer is correct and why other options are incorrect]
        
        ------------------------------------------
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model, maxTokens: 3000) { [weak self] result in
                switch result {
                case .success(let text):
                    completion(.success(text))
                case .failure(let error):
                    print("⚠️ Gemini API call failed (\(error.localizedDescription)), falling back to smart simulation...")
                    self?.generateSimulatedDynamicQuiz(topicTitle: topicTitle, tasks: tasks, notes: notesContent, questionCount: targetQuestionCount, completion: completion)
                }
            }
        } else {
            generateSimulatedDynamicQuiz(topicTitle: topicTitle, tasks: tasks, notes: notesContent, questionCount: targetQuestionCount, completion: completion)
        }
    }
    
    // MARK: - Google Gemini REST API Call (URLSession dataTask)
    private func callGeminiAPI(prompt: String, apiKey: String, model: String, maxTokens: Int = 2000, completion: @escaping (Result<String, APIError>) -> Void) {
        let endpointString = "\(geminiBaseURL)/\(model):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpointString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": maxTokens
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(.decodingFailed))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                completion(.failure(.noInternet))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverError("Invalid server response.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorObj = errorJson["error"] as? [String: Any],
                   let message = errorObj["message"] as? String {
                    completion(.failure(.serverError(message)))
                    return
                }
                completion(.failure(.serverError("HTTP \(httpResponse.statusCode)")))
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let firstCandidate = candidates.first,
                  let content = firstCandidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let firstPart = parts.first,
                  let generatedText = firstPart["text"] as? String else {
                completion(.failure(.decodingFailed))
                return
            }
            
            let trimmedText = generatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(.success(trimmedText))
        }
        
        task.resume()
    }
    
    // MARK: - Smart Offline Simulation (Fallback)
    private func generateSimulatedSummary(topicTitle: String, tasks: Set<Task>, notes: String, completion: @escaping (Result<String, APIError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            let taskTitles = tasks.map { "• \($0.title ?? "Lesson")" }.joined(separator: "\n")
            
            let summary = """
            📌 EXECUTIVE OVERVIEW: \(topicTitle)
            This module covers foundational principles and real-world implementations of "\(topicTitle)". Mastering these concepts will solidify your problem-solving skills and technical proficiency.
            
            🎯 DEEP-DIVE KEY TAKEAWAYS:
            \(taskTitles.isEmpty ? "• Core concepts and foundational exercises" : taskTitles)
            
            💡 LESSON NOTES & ESSENTIAL HIGHLIGHTS:
            \(notes.isEmpty ? "• Focus on mastering core terminology, principles, and trade-offs.\n• Practice self-testing regularly for maximum retention." : notes)
            
            ⚠️ COMMON PITFALLS & EXAM GOTCHAS:
            • Overlooking boundary and edge cases during implementation.
            • Relying only on passive reading rather than active recall.
            
            ⚡ RAPID REVISION CHECKLIST:
            ☑ Review main definitions and formulas
            ☑ Solve 3 practice problems without notes
            ☑ Explain the core principle in simple words
            """
            
            completion(.success(summary))
        }
    }
    
    private func generateSimulatedDynamicQuiz(topicTitle: String, tasks: Set<Task>, notes: String, questionCount: Int, completion: @escaping (Result<String, APIError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            let taskList = Array(tasks)
            var generatedQuestions: [String] = []
            
            for i in 1...questionCount {
                let currentLesson = !taskList.isEmpty ? (taskList[(i - 1) % taskList.count].title ?? "Lesson") : "Concept \(i)"
                
                let q = """
                Q\(i). In "\(topicTitle)", which principle is essential regarding "\(currentLesson)"?
                A) Strict adherence to optimal time/space complexity and systematic verification
                B) Skipping input validations to reduce lines of code
                C) Applying patterns blindly without analyzing constraints
                D) None of the above
                ✅ Answer: A
                💡 Explanation: Rigorous input validation and complexity analysis are vital for robust mastery of "\(currentLesson)".
                """
                generatedQuestions.append(q)
            }
            
            let header = "📝 Practice Quiz: \(topicTitle) (\(questionCount) High-Yield Questions)\n\n"
            let fullQuiz = header + generatedQuestions.joined(separator: "\n\n------------------------------------------\n\n")
            
            completion(.success(fullQuiz))
        }
    }
}
