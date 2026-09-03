//
//  AIService.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Handles dynamic StudyMate AI Tutor Q&A, Notes Summarization, and interactive Practice Quiz Generation.
//

import Foundation

// MARK: - Interactive Quiz Models
struct QuizQuestion {
    let id: String = UUID().uuidString
    let questionNumber: Int
    let questionText: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
    var isAnswerRevealed: Bool = false
}

struct AIChatMessage {
    let isUser: Bool
    let text: String
}

class AIService {
    
    // MARK: - Singleton
    static let shared = AIService()
    private init() {}
    
    // Google Gemini API Base Endpoint
    private let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    // MARK: - Helper: Format Topic Notes Context
    private func getNotesContext(for topic: Topic) -> (notesContent: String, taskCount: Int) {
        let tasks = (topic.tasks as? Set<Task>) ?? []
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
        return (notesContent, tasks.count)
    }
    
    // MARK: - Dynamic Question Count Calculator
    private func calculateTargetQuizCount(notesContent: String, taskCount: Int) -> Int {
        let characterCount = notesContent.count
        if characterCount < 250 {
            return max(3, taskCount * 2)
        } else if characterCount < 700 {
            return max(4, taskCount * 2)
        } else if characterCount < 1500 {
            return max(5, taskCount * 2)
        } else {
            return min(8, max(6, taskCount * 3))
        }
    }
    
    // MARK: - 1. Ask Study Tutor (Context-Aware Q&A with Memory)
    /// Answers the student's question grounded specifically in the module's lesson notes, maintaining conversation history.
    func askStudyTutor(for topic: Topic, history: [AIChatMessage], completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let courseName = topic.course?.name ?? "General Study"
        let (notesContent, _) = getNotesContext(for: topic)
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are "StudyMate AI Tutor", a helpful, encouraging, and clear academic tutor.
        The student is studying the course "\(courseName)", specifically the module "\(topicTitle)".
        
        Here are the student's lesson notes for this module:
        \"\"\"
        \(notesContent.isEmpty ? "No detailed lesson notes written yet for \(topicTitle)." : notesContent)
        \"\"\"
        
        INSTRUCTIONS:
        1. If the question is related to the module "\(topicTitle)" or the notes, answer it using the lesson notes as primary context. If the notes lack details, provide a standard academic explanation.
        2. If the question is entirely unrelated to the module (e.g., general knowledge, casual chat, or completely different topics), handle it normally like a general AI assistant. You do not need to restrict yourself to the module.
        3. Use clear bullet points, brief examples, or code/math formulas where appropriate. Keep explanations engaging and easy to understand.
        """
        
        var apiContents: [[String: Any]] = []
        
        // Seed the system prompt as the first interaction
        apiContents.append(["role": "user", "parts": [["text": prompt]]])
        apiContents.append(["role": "model", "parts": [["text": "Understood. I am ready to help the student!"]]])
        
        // Append conversation history
        var currentRole = ""
        var combinedText = ""
        
        func flush() {
            if !combinedText.isEmpty {
                apiContents.append(["role": currentRole, "parts": [["text": combinedText]]])
            }
        }
        
        for msg in history {
            let role = msg.isUser ? "user" : "model"
            if role == currentRole {
                combinedText += "\n\n" + msg.text
            } else {
                flush()
                currentRole = role
                combinedText = msg.text
            }
        }
        flush()
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(contents: apiContents, apiKey: apiKey, model: model, maxTokens: 1800) { result in
                switch result {
                case .success(let text):
                    completion(.success(text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.serverError("Please enter your Gemini API Key in Settings to chat with the AI.")))
        }
    }
    
    // MARK: - 2. Generate AI Summary
    /// Generates a structured revision summary tailored to the depth of the notes
    func generateSummary(for topic: Topic, completion: @escaping (Result<String, APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let courseName = topic.course?.name ?? "General Study"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        let (notesContent, _) = getNotesContext(for: topic)
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are "StudyMate AI Tutor", an elite academic study coach.
        Course: "\(courseName)"
        Module: "\(topicTitle)"
        
        Study Notes:
        \"\"\"
        \(notesContent.isEmpty ? "No detailed lesson notes written yet. Generate a structured master summary for the module: \(topicTitle)." : notesContent)
        \"\"\"
        
        TASK:
        Generate a structured study summary based on the notes above:
        
        📌 EXECUTIVE OVERVIEW
        (Core concepts and real-world importance)
        
        🎯 KEY TAKEAWAYS & LESSON PRINCIPLES
        (Key bullet points covering important mechanisms)
        
        💡 FORMULAS, DEFINITIONS & HIGHLIGHTS
        (Important terms, definitions, and equations)
        
        ⚠️ COMMON PITFALLS & EXAM GOTCHAS
        (Frequent misunderstandings to watch out for)
        
        ⚡ RAPID REVISION CHECKLIST
        (4-6 quick check points)
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model, maxTokens: 2500) { result in
                switch result {
                case .success(let text):
                    completion(.success(text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.serverError("Please enter your Gemini API Key in Settings to generate a summary.")))
        }
    }
    
    // MARK: - 3. Generate Structured Practice Quiz
    /// Generates practice questions with separate options, hidden answers, and explanations
    func generateStructuredQuiz(for topic: Topic, completion: @escaping (Result<[QuizQuestion], APIError>) -> Void) {
        guard UserDefaultsManager.shared.isAIEnabled else {
            completion(.failure(.aiDisabled))
            return
        }
        
        let topicTitle = topic.title ?? "General Topic"
        let courseName = topic.course?.name ?? "General Study"
        let tasks = (topic.tasks as? Set<Task>) ?? []
        let (notesContent, taskCount) = getNotesContext(for: topic)
        let targetCount = calculateTargetQuizCount(notesContent: notesContent, taskCount: taskCount)
        
        let apiKey = UserDefaultsManager.shared.customAPIKey ?? ""
        let model = UserDefaultsManager.shared.aiModelName
        
        let prompt = """
        You are "StudyMate AI Tutor", an expert exam question creator.
        Course: "\(courseName)"
        Module: "\(topicTitle)"
        
        Study Notes:
        \"\"\"
        \(notesContent.isEmpty ? "Academic subject knowledge for \(topicTitle)." : notesContent)
        \"\"\"
        
        TASK:
        Generate EXACTLY \(targetCount) Multiple Choice Practice Questions (MCQs) based on the notes.
        
        Format each question strictly with this exact structure:
        
        [QUESTION_START]
        Number: 1
        Question: [Question Text]
        A: [Option A text]
        B: [Option B text]
        C: [Option C text]
        D: [Option D text]
        Answer: A
        Explanation: [Detailed explanation of why this answer is correct and others are wrong]
        [QUESTION_END]
        """
        
        if !apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            callGeminiAPI(prompt: prompt, apiKey: apiKey, model: model, maxTokens: 2500) { [weak self] result in
                switch result {
                case .success(let rawText):
                    let parsed = self?.parseQuizQuestions(from: rawText) ?? []
                    if !parsed.isEmpty {
                        completion(.success(parsed))
                    } else {
                        completion(.failure(.decodingFailed))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.serverError("Please enter your Gemini API Key in Settings to generate a quiz.")))
        }
    }
    
    // MARK: - Quiz Text Parser
    func parseQuizQuestions(from rawText: String) -> [QuizQuestion] {
        var results: [QuizQuestion] = []
        let blocks = rawText.components(separatedBy: "[QUESTION_START]")
        
        for (idx, block) in blocks.enumerated() {
            guard block.contains("Question:") && block.contains("Answer:") else { continue }
            
            var questionText = ""
            var options: [String] = []
            var answer = "A"
            var explanation = "Review the core concepts in your notes."
            
            let lines = block.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("Question:") {
                    questionText = trimmed.replacingOccurrences(of: "Question:", with: "").trimmingCharacters(in: .whitespaces)
                } else if trimmed.hasPrefix("A:") || trimmed.hasPrefix("A)") {
                    options.append(trimmed)
                } else if trimmed.hasPrefix("B:") || trimmed.hasPrefix("B)") {
                    options.append(trimmed)
                } else if trimmed.hasPrefix("C:") || trimmed.hasPrefix("C)") {
                    options.append(trimmed)
                } else if trimmed.hasPrefix("D:") || trimmed.hasPrefix("D)") {
                    options.append(trimmed)
                } else if trimmed.hasPrefix("Answer:") {
                    answer = trimmed.replacingOccurrences(of: "Answer:", with: "").trimmingCharacters(in: .whitespaces)
                } else if trimmed.hasPrefix("Explanation:") {
                    explanation = trimmed.replacingOccurrences(of: "Explanation:", with: "").trimmingCharacters(in: .whitespaces)
                }
            }
            
            if !questionText.isEmpty && options.count >= 2 {
                let q = QuizQuestion(
                    questionNumber: results.count + 1,
                    questionText: questionText,
                    options: options,
                    correctAnswer: answer,
                    explanation: explanation,
                    isAnswerRevealed: false
                )
                results.append(q)
            }
        }
        
        return results
    }
    
    // MARK: - Google Gemini REST API Call
    private func callGeminiAPI(prompt: String? = nil, contents: [[String: Any]]? = nil, apiKey: String, model: String, maxTokens: Int = 2000, completion: @escaping (Result<String, APIError>) -> Void) {
        let endpointString = "\(geminiBaseURL)/\(model):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpointString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let finalContents: [[String: Any]]
        if let contents = contents {
            finalContents = contents
        } else if let prompt = prompt {
            finalContents = [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        } else {
            completion(.failure(.missingData))
            return
        }
        
        let payload: [String: Any] = [
            "contents": finalContents,
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
    
}

