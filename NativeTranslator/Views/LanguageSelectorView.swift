import SwiftUI

struct LanguageSelectorView: View {
    @Binding var selectedLanguage: Language
    let languages: [Language]
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(languages) { language in
                Button(action: {
                    selectedLanguage = language
                    dismiss()
                }) {
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        Text(language.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedLanguage.code == language.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}