import SwiftUI

struct HistoryListView: View {
    @ObservedObject var historyManager: TranslationHistoryManager
    @Binding var isPresented: Bool
    let onSelect: (TranslationHistoryItem) -> Void
    @State private var searchText = ""
    
    var filteredItems: [TranslationHistoryItem] {
        if searchText.isEmpty {
            return historyManager.items
        } else {
            return historyManager.items.filter { item in
                item.sourceText.localizedCaseInsensitiveContains(searchText) ||
                item.translatedText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if historyManager.items.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Translation History")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Your recent translations will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // History list
                    List {
                        ForEach(filteredItems) { item in
                            Button(action: {
                                onSelect(item)
                                isPresented = false
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Languages and time
                                    HStack {
                                        Text("\(item.sourceLanguageName) → \(item.targetLanguageName)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Text(item.formattedDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Source text preview
                                    Text(item.previewText)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    
                                    // Translated text preview
                                    Text(item.translatedText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    // Context indicator if present
                                    if let context = item.context, !context.isEmpty {
                                        HStack {
                                            Image(systemName: "text.bubble")
                                                .font(.caption2)
                                            Text("With context")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onDelete { indexSet in
                            historyManager.items.remove(atOffsets: indexSet)
                            historyManager.saveHistory()
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search history")
                }
            }
            .navigationTitle("Translation History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        isPresented = false
                    }
                }
                
                if !historyManager.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                historyManager.clearHistory()
                            } label: {
                                Label("Clear All History", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

// Extension to make save history accessible
extension TranslationHistoryManager {
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "TranslationHistory")
        }
    }
}