import Foundation

struct TranslationRequest: Codable {
    let text: String
    let context: String?
    let sourceLanguage: String
    let targetLanguage: String
}

struct TranslationResponse: Codable {
    let success: Bool
    let data: TranslationData?
    let error: ErrorData?
}

struct TranslationData: Codable {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let context: String?
    let timestamp: String
}

struct ErrorData: Codable {
    let message: String
    let details: String?
}