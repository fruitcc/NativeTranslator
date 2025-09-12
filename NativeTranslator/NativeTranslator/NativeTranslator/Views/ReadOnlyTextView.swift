import SwiftUI
import UIKit

// Custom UITextView wrapper that allows selection but prevents editing
struct ReadOnlyTextView: UIViewRepresentable {
    let text: String
    let placeholder: String
    let font: UIFont
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false // Prevent editing
        textView.isSelectable = true // Allow text selection
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.systemGray6
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Set data detector types to make links clickable
        textView.dataDetectorTypes = .all
        
        // Ensure the text view is user interactive
        textView.isUserInteractionEnabled = true
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.placeholderText
        } else {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
    }
}