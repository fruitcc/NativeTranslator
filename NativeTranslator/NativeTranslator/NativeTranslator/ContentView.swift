import SwiftUI

struct ContentView: View {
    @StateObject private var translationService = TranslationService()
    @StateObject private var historyManager = TranslationHistoryManager()
    @State private var sourceText = ""
    @State private var translatedText = ""
    @AppStorage("sourceLanguageCode") private var sourceLanguageCode = "auto"
    @AppStorage("targetLanguageCode") private var targetLanguageCode = "en"
    @AppStorage("translationContext") private var context = ""
    @State private var sourceLanguage = Language.availableLanguages[0]
    @State private var targetLanguage = Language.availableTargetLanguages[0]
    @State private var showContextPopup = false
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var isTranslating = false
    @State private var errorMessage = ""
    @State private var showError = false
    @FocusState private var isSourceTextFocused: Bool
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
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSourceTextFocused = false
                    }
                    .fontWeight(.semibold)
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
        .sheet(isPresented: $showHistory) {
            HistoryListView(
                historyManager: historyManager,
                isPresented: $showHistory,
                onSelect: { item in
                    // Load the selected history item
                    sourceText = item.sourceText
                    translatedText = item.translatedText
                    
                    // Update languages
                    if let sourceLang = Language.availableLanguages.first(where: { $0.code == item.sourceLanguageCode }) {
                        sourceLanguage = sourceLang
                        sourceLanguageCode = sourceLang.code
                    }
                    if let targetLang = Language.availableTargetLanguages.first(where: { $0.code == item.targetLanguageCode }) {
                        targetLanguage = targetLang
                        targetLanguageCode = targetLang.code
                    }
                    
                    // Restore context if available
                    if let historyContext = item.context {
                        context = historyContext
                    }
                }
            )
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
            },
            onClear: {
                sourceText = ""
                isSourceTextFocused = true
            },
            onShowHistory: {
                showHistory = true
            },
            focusBinding: $isSourceTextFocused
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
            },
            onClear: nil,
            onShowHistory: nil
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
                
                // Swap text content between source and target
                let tempText = sourceText
                sourceText = translatedText
                translatedText = tempText
                // Do NOT automatically trigger translation - let user decide when to translate
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
                    
                    // Save to history
                    let historyItem = TranslationHistoryItem(
                        sourceText: sourceText,
                        translatedText: translatedText,
                        sourceLanguage: sourceLanguage,
                        targetLanguage: targetLanguage,
                        context: context.isEmpty ? nil : context
                    )
                    historyManager.addItem(historyItem)
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