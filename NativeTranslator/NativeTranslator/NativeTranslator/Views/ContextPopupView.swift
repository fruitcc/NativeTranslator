import SwiftUI

struct ContextPopupView: View {
    @Binding var context: String
    @Binding var isPresented: Bool
    @State private var tempContext: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Provide context for more accurate translations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Context (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !tempContext.isEmpty {
                            Text("\(tempContext.count) characters")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    TextEditor(text: $tempContext)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Examples:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Formal business email")
                        Text("• Casual conversation with friends")
                        Text("• Medical document")
                        Text("• Technical manual")
                        Text("• Restaurant menu")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Translation Context")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        context = tempContext
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempContext = context
        }
    }
}