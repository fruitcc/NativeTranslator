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
                                VStack(alignment: .leading, spacing: 6) {
                                    // Languages and time
                                    HStack {
                                        Text("\(item.sourceLanguageName) → \(item.targetLanguageName)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        // Context indicator if present
                                        if let context = item.context, !context.isEmpty {
                                            Image(systemName: "text.bubble.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(item.formattedDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Source text - show more lines
                                    Text(item.sourceText)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    historyManager.items.removeAll { $0.id == item.id }
                                    historyManager.saveHistory()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            // When searching, we need to find the actual items to delete
                            let itemsToDelete = indexSet.map { filteredItems[$0] }
                            historyManager.items.removeAll { item in
                                itemsToDelete.contains { $0.id == item.id }
                            }
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

