import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),  // Light blue
                    Color(red: 0.1, green: 0.3, blue: 0.7)   // Darker blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main translation symbol
            VStack(spacing: size * 0.05) {
                // Translation arrows with text
                HStack(spacing: size * 0.06) {
                    // Source language symbol
                    Text("A")
                        .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Arrow
                    Image(systemName: "arrow.right")
                        .font(.system(size: size * 0.15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Target language symbol (Japanese character)
                    Text("あ")
                        .font(.system(size: size * 0.28, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.2), radius: size * 0.02, x: 0, y: size * 0.01)
            }
            
            // Globe watermark
            Image(systemName: "globe")
                .font(.system(size: size * 0.25, weight: .ultraLight))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: -size * 0.3, y: -size * 0.3)
                .rotationEffect(.degrees(-15))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237))
    }
}

// Preview to help visualize
struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // App Store size
            AppIconView(size: 1024)
                .previewDisplayName("App Store (1024x1024)")
            
            // iPhone size
            AppIconView(size: 180)
                .previewDisplayName("iPhone (180x180)")
            
            // Small size
            AppIconView(size: 60)
                .previewDisplayName("Small (60x60)")
        }
    }
}

// Simple view to export as image
struct ExportableAppIcon: View {
    var body: some View {
        AppIconView(size: 1024)
            .background(Color.clear)
    }
}