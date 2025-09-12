import Foundation

struct Language: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    
    static let availableLanguages = [
        Language(code: "auto", name: "Auto-detect", flag: "🌐"),
        Language(code: "en", name: "English", flag: "🇬🇧"),
        Language(code: "es", name: "Spanish", flag: "🇪🇸"),
        Language(code: "fr", name: "French", flag: "🇫🇷"),
        Language(code: "de", name: "German", flag: "🇩🇪"),
        Language(code: "it", name: "Italian", flag: "🇮🇹"),
        Language(code: "pt", name: "Portuguese", flag: "🇵🇹"),
        Language(code: "ru", name: "Russian", flag: "🇷🇺"),
        Language(code: "ja", name: "Japanese", flag: "🇯🇵"),
        Language(code: "ko", name: "Korean", flag: "🇰🇷"),
        Language(code: "zh", name: "Chinese (Simplified)", flag: "🇨🇳"),
        Language(code: "zh-TW", name: "Chinese (Traditional)", flag: "🇹🇼"),
        Language(code: "ar", name: "Arabic", flag: "🇸🇦"),
        Language(code: "hi", name: "Hindi", flag: "🇮🇳"),
        Language(code: "nl", name: "Dutch", flag: "🇳🇱"),
        Language(code: "pl", name: "Polish", flag: "🇵🇱"),
        Language(code: "tr", name: "Turkish", flag: "🇹🇷"),
        Language(code: "vi", name: "Vietnamese", flag: "🇻🇳"),
        Language(code: "th", name: "Thai", flag: "🇹🇭"),
        Language(code: "id", name: "Indonesian", flag: "🇮🇩"),
        Language(code: "sv", name: "Swedish", flag: "🇸🇪")
    ]
    
    static let availableTargetLanguages = availableLanguages.filter { $0.code != "auto" }
}