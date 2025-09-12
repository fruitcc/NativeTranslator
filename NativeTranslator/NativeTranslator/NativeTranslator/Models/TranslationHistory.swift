import Foundation

struct TranslationHistoryItem: Codable, Identifiable {
    let id = UUID()
    let sourceText: String
    let translatedText: String
    let sourceLanguageCode: String
    let targetLanguageCode: String
    let sourceLanguageName: String
    let targetLanguageName: String
    let timestamp: Date
    let context: String?
    
    init(sourceText: String,
         translatedText: String,
         sourceLanguage: Language,
         targetLanguage: Language,
         context: String? = nil) {
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguageCode = sourceLanguage.code
        self.targetLanguageCode = targetLanguage.code
        self.sourceLanguageName = sourceLanguage.name
        self.targetLanguageName = targetLanguage.name
        self.timestamp = Date()
        self.context = context
    }
    
    // Preview text for display in history list
    var previewText: String {
        if sourceText.count > 50 {
            return String(sourceText.prefix(50)) + "..."
        }
        return sourceText
    }
    
    // Formatted date for display
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

class TranslationHistoryManager: ObservableObject {
    @Published var items: [TranslationHistoryItem] = []
    private let maxItems = 100
    private let storageKey = "TranslationHistory"
    
    init() {
        loadHistory()
    }
    
    func addItem(_ item: TranslationHistoryItem) {
        // Add new item at the beginning
        items.insert(item, at: 0)
        
        // Keep only the last maxItems
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        items.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TranslationHistoryItem].self, from: data) {
            items = decoded
        }
    }
}