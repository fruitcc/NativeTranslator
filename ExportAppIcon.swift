import SwiftUI
import UIKit

// Script to export the AppIconView as an image file
struct IconExporter {
    static func exportIcon() {
        // Create the SwiftUI view
        let iconView = AppIconView(size: 1024)
        
        // Create a hosting controller
        let controller = UIHostingController(rootView: iconView)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        controller.view.backgroundColor = .clear
        
        // Render to image
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
        let image = renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
        
        // Save to desktop
        if let data = image.pngData() {
            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            let fileURL = desktopURL.appendingPathComponent("NativeTranslator-AppIcon-1024.png")
            
            do {
                try data.write(to: fileURL)
                print("✅ App icon exported to: \(fileURL.path)")
                print("You can now use this in Xcode's Assets.xcassets")
            } catch {
                print("❌ Failed to save icon: \(error)")
            }
        }
    }
}

// Add this temporary button to your ContentView to trigger export
struct ExportIconButton: View {
    var body: some View {
        Button("Export App Icon") {
            IconExporter.exportIcon()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}