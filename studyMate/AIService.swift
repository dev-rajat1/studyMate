//
//  AIService.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Handles AI Notes Summarization and Quiz Generation using Google Gemini API (gemini-3.7-flash) with URLSession dataTask.
//

import Foundation

class AIService {
    
    // MARK: - Singleton
    static let shared = AIService()
    private init() {}
    
    // Google Gemini API Base Endpoint
    private let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    // MARK: - Generate AI Summary
    /// Generates a structured revision summary for a given Topic and its task notes using Gemini AI
    func generateSummary(for topic: Topic, completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        
        // Collect notes from all tasks under this topic
        let notesContent = tasks.compactMap { task -> String? in
            guard let notes = task.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return "- [\(task.title ?? "Task")]: \(notes)"
        }.joined(separator: "\n")
        
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are an expert study tutor for students. Generate a concise, high-yield study revision summary for the topic: "\(topicTitle)".
        
        Student's Notes and Task Details:
        \(notesContent.isEmpty ? "No specific sub-notes provided. Generate a comprehensive fundamental summary of \(topicTitle)." : notesContent)
        
        Please format the response clearly with:
        📚 Summary Overview
        🎯 Key Concepts & Takeaways (bullet points)
        💡 Common Pitfalls & Tips
        ⚡ Quick Revision Note
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model) { [weak self] result in
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
    
    // MARK: - Generate AI Quiz
    /// Generates 3-4 interactive practice quiz questions with explanations for revision
    func generateQuiz(for topic: Topic, completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        let notesContent = tasks.compactMap { $0.notes }.joined(separator: "; ")
        
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are an academic test maker. Generate 3 high-yield Multiple Choice Practice Quiz questions (MCQs) for the topic: "\(topicTitle)".
        Context Notes: \(notesContent.isEmpty ? "General subject knowledge." : notesContent)
        
        For each question format exactly as:
        Q1. [Question]
        A) [Option A]
        B) [Option B]
        C) [Option C]
        D) [Option D]
        ✅ Answer: [Correct Letter]
        💡 Explanation: [Brief explanation]
        
        ------------------------------------------
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model) { [weak self] result in
                switch result {
                case .success(let text):
                    completion(.success(text))
                case .failure(let error):
                    print("⚠️ Gemini API call failed (\(error.localizedDescription)), falling back to smart simulation...")
                    self?.generateSimulatedQuiz(topicTitle: topicTitle, tasks: tasks, completion: completion)
                }
            }
        } else {
            generateSimulatedQuiz(topicTitle: topicTitle, tasks: tasks, completion: completion)
        }
    }
    
    // MARK: - Google Gemini REST API Call (URLSession dataTask)
    private func callGeminiAPI(prompt: String, apiKey: String, model: String, completion: @escaping (Result<String, APIError>) -> Void) {
        let endpointString = "\(geminiBaseURL)/\(model):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpointString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 25.0
        
        // Gemini JSON Payload structure
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
                "maxOutputTokens": 1000
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
                // Attempt to parse error message from Gemini JSON
                if let errorJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorObj = errorJson["error"] as? [String: Any],
                   let message = errorObj["message"] as? String {
                    completion(.failure(.serverError(message)))
                    return
                }
                completion(.failure(.serverError("HTTP \(httpResponse.statusCode)")))
                return
            }
            
            // Parse Gemini Response: candidates[0].content.parts[0].text
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
            let taskTitles = tasks.map { "• \($0.title ?? "Task")" }.joined(separator: "\n")
            
            let summary = """
            📚 AI Study Summary: \(topicTitle)
            
            📌 Overview:
            This topic covers the fundamental principles and implementation details of "\(topicTitle)". Mastering these concepts will solidify your understanding and practical problem-solving skills.
            
            🎯 Key Topics & Tasks:
            \(taskTitles.isEmpty ? "• Core concepts and foundational exercises" : taskTitles)
            
            💡 Important Notes & Takeaways:
            \(notes.isEmpty ? "• Focus on mastering core terminology, time complexities, and real-world trade-offs.\n• Practice writing code without auto-completion for better retention." : notes)
            
            ⚡ Pro Study Tip:
            Use the Feynman Technique: Try explaining this topic in simple terms to a peer without looking at the notes!
            """
            
            completion(.success(summary))
        }
    }
    
    private func generateSimulatedQuiz(topicTitle: String, tasks: Set<Task>, completion: @escaping (Result<String, APIError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            let sampleTaskName = tasks.first?.title ?? "Core Concept"
            
            let quiz = """
            📝 Practice Quiz: \(topicTitle)
            
            Q1. What is the primary purpose of studying "\(topicTitle)"?
            A) To optimize execution and code maintainability
            B) To increase code complexity unnecessarily
            C) Only for theoretical examinations
            D) None of the above
            ✅ Answer: A
            💡 Explanation: Understanding "\(topicTitle)" helps in writing efficient, scalable, and maintainable software.
            
            ------------------------------------------
            
            Q2. In the context of "\(sampleTaskName)", what is the best practice?
            A) Ignoring edge cases
            B) Validating inputs and handling error states gracefully
            C) Running heavy computations on the main thread
            D) Hardcoding values
            ✅ Answer: B
            💡 Explanation: Defensive programming and proper error handling ensure application stability.
            
            ------------------------------------------
            
            Q3. How often should you revise this topic for long-term retention?
            A) Never again
            B) Spaced repetition (Day 1, Day 3, Day 7)
            C) Only before the exam night
            D) Once a year
            ✅ Answer: B
            💡 Explanation: Spaced repetition is scientifically proven to boost memory retention by over 80%.
            """
            
            completion(.success(quiz))
        }
    }
}
