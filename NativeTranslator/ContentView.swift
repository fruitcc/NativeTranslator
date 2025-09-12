import SwiftUI

struct ContentView: View {
    @StateObject private var translationService = TranslationService()
    @State private var sourceText = ""
    @State private var translatedText = ""
    @State private var sourceLanguage = Language.availableLanguages[0] // Auto-detect
    @State private var targetLanguage = Language.availableTargetLanguages[0] // English
    @State private var context = ""
    @State private var showContextPopup = false
    @State private var isTranslating = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLandscape {
                    // Horizontal layout for landscape
                    HStack(spacing: 0) {
                        translationBoxes
                    }
                } else {
                    // Vertical layout for portrait
                    VStack(spacing: 0) {
                        translationBoxes
                    }
                }
            }
            .navigationTitle("Native Translator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showContextPopup = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "text.bubble")
                            if !context.isEmpty {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await performTranslation()
                        }
                    }) {
                        if isTranslating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Text("Translate")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(sourceText.isEmpty || isTranslating)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showContextPopup) {
            ContextPopupView(context: $context, isPresented: $showContextPopup)
        }
        .alert("Translation Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    var translationBoxes: some View {
        TranslationBoxView(
            title: "Source",
            text: $sourceText,
            selectedLanguage: $sourceLanguage,
            availableLanguages: Language.availableLanguages,
            isSource: true,
            onCopy: {
                UIPasteboard.general.string = sourceText
            },
            onPaste: {
                if let pastedText = UIPasteboard.general.string {
                    sourceText = pastedText
                }
            }
        )
        
        Divider()
        
        TranslationBoxView(
            title: "Target",
            text: $translatedText,
            selectedLanguage: $targetLanguage,
            availableLanguages: Language.availableTargetLanguages,
            isSource: false,
            onCopy: {
                UIPasteboard.general.string = translatedText
            },
            onPaste: {
                // Paste is disabled for target box as it's read-only
            }
        )
    }
    
    func performTranslation() async {
        isTranslating = true
        errorMessage = ""
        
        do {
            let response = try await translationService.translate(
                text: sourceText,
                from: sourceLanguage.code,
                to: targetLanguage.code,
                context: context.isEmpty ? nil : context
            )
            
            await MainActor.run {
                if response.success, let data = response.data {
                    translatedText = data.translatedText
                } else if let error = response.error {
                    errorMessage = error.message
                    showError = true
                }
                isTranslating = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isTranslating = false
            }
        }
    }
}