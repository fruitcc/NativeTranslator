import SwiftUI

struct TranslationBoxView: View {
    let title: String
    @Binding var text: String
    @Binding var selectedLanguage: Language
    let availableLanguages: [Language]
    let isSource: Bool
    let onCopy: () -> Void
    @State private var showLanguageSelector = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    showLanguageSelector = true
                }) {
                    HStack(spacing: 8) {
                        Text(selectedLanguage.flag)
                            .font(.title2)
                        Text(selectedLanguage.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Show keyboard dismiss button only for source input when keyboard is active
                if isSource && isTextFieldFocused {
                    Button(action: {
                        isTextFieldFocused = false
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                }
                
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 18))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            // Text Area
            if isSource {
                TextEditor(text: $text)
                    .padding(12)
                    .font(.system(size: 18))
                    .scrollContentBackground(.hidden)
                    .background(Color(UIColor.systemGray6))
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
            } else {
                TextEditor(text: .constant(text.isEmpty ? "Translation will appear here" : text))
                    .padding(12)
                    .font(.system(size: 18))
                    .foregroundColor(text.isEmpty ? .gray : .primary)
                    .scrollContentBackground(.hidden)
                    .background(Color(UIColor.systemGray6))
                    .disabled(false) // Allow text selection but not editing
            }
        }
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView(
                selectedLanguage: $selectedLanguage,
                languages: availableLanguages,
                title: "Select \(title) Language"
            )
        }
    }
}