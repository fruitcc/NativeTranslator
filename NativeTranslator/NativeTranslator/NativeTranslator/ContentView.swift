import SwiftUI

struct ContentView: View {
    @StateObject private var translationService = TranslationService()
    @State private var sourceText = ""
    @State private var translatedText = ""
    @AppStorage("sourceLanguageCode") private var sourceLanguageCode = "auto"
    @AppStorage("targetLanguageCode") private var targetLanguageCode = "en"
    @AppStorage("translationContext") private var context = ""
    @State private var sourceLanguage = Language.availableLanguages[0]
    @State private var targetLanguage = Language.availableTargetLanguages[0]
    @State private var showContextPopup = false
    @State private var showSettings = false
    @State private var isTranslating = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var canSwapLanguages: Bool {
        // Can swap if source is not auto-detect
        sourceLanguage.code != "auto"
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
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Native Translator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                        
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
                .onDisappear {
                    // Context is automatically saved via @AppStorage
                }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
        }
        .alert("Translation Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Load saved language preferences
            sourceLanguage = Language.availableLanguages.first { $0.code == sourceLanguageCode } ?? Language.availableLanguages[0]
            targetLanguage = Language.availableTargetLanguages.first { $0.code == targetLanguageCode } ?? Language.availableTargetLanguages[0]
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
            }
        )
        .onChange(of: sourceLanguage) { newValue in
            sourceLanguageCode = newValue.code
        }
        
        // Swap button between the boxes with different icons for orientation
        ZStack {
            Divider()
            
            Button(action: swapLanguages) {
                Image(systemName: isLandscape ? "arrow.left.arrow.right" : "arrow.up.arrow.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(canSwapLanguages ? .blue : .gray)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .disabled(!canSwapLanguages)
        }
        
        TranslationBoxView(
            title: "Target",
            text: $translatedText,
            selectedLanguage: $targetLanguage,
            availableLanguages: Language.availableTargetLanguages,
            isSource: false,
            onCopy: {
                UIPasteboard.general.string = translatedText
            }
        )
        .onChange(of: targetLanguage) { newValue in
            targetLanguageCode = newValue.code
        }
    }
    
    func swapLanguages() {
        guard canSwapLanguages else { return }
        
        // Swap the languages
        let tempLanguageCode = sourceLanguageCode
        
        // Find the source language in target languages (skip auto-detect)
        if let newTargetLang = Language.availableTargetLanguages.first(where: { $0.code == tempLanguageCode && $0.code != "auto" }) {
            // Find the target language in source languages
            if let newSourceLang = Language.availableLanguages.first(where: { $0.code == targetLanguageCode }) {
                // Swap languages
                sourceLanguage = newSourceLang
                sourceLanguageCode = newSourceLang.code
                targetLanguage = newTargetLang
                targetLanguageCode = newTargetLang.code
                
                // Swap text content only if there's translated text
                if !translatedText.isEmpty {
                    let tempText = sourceText
                    sourceText = translatedText
                    translatedText = tempText
                    
                    // Trigger new translation immediately if we have source text
                    if !sourceText.isEmpty {
                        Task {
                            await performTranslation()
                        }
                    }
                }
            }
        }
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