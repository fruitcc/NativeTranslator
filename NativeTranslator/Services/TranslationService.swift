import Foundation

class TranslationService: ObservableObject {
    private let baseURL = "http://localhost:3001/api"
    
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String, context: String?) async throws -> TranslationResponse {
        guard let url = URL(string: "\(baseURL)/translate") else {
            throw TranslationError.invalidURL
        }
        
        let request = TranslationRequest(
            text: text,
            context: context,
            sourceLanguage: sourceLanguage == "auto" ? "en" : sourceLanguage, // Default to English for auto-detect
            targetLanguage: targetLanguage
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw TranslationError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(TranslationResponse.self, from: data)
    }
}

enum TranslationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        }
    }
}