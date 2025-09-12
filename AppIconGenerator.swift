import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.9),  // Light blue
                    Color(red: 0.1, green: 0.4, blue: 0.8)   // Darker blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main content
            VStack(spacing: 20) {
                // Top language bubble (source)
                HStack(spacing: 15) {
                    Text("A")
                        .font(.system(size: 140, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 80, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("あ")
                        .font(.system(size: 140, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            
            // Globe accent in corner
            Image(systemName: "globe")
                .font(.system(size: 100, weight: .light))
                .foregroundColor(.white.opacity(0.15))
                .offset(x: -180, y: -180)
                .rotationEffect(.degrees(-15))
        }
        .frame(width: 512, height: 512)
        .clipShape(RoundedRectangle(cornerRadius: 112))
    }
}

// Preview for generating the icon
struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
            .previewLayout(.fixed(width: 512, height: 512))
    }
}

// Alternative minimalist design
struct AppIconMinimalView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.9),  // Purple
                    Color(red: 0.2, green: 0.5, blue: 0.9)   // Blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Translation symbol
            VStack(spacing: 0) {
                // Speech bubbles overlapping
                ZStack {
                    // Left bubble
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 280, height: 180)
                        .offset(x: -40, y: -20)
                        .overlay(
                            Text("Hello")
                                .font(.system(size: 60, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                .offset(x: -40, y: -20)
                        )
                    
                    // Right bubble
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 280, height: 180)
                        .offset(x: 40, y: 20)
                        .overlay(
                            Text("你好")
                                .font(.system(size: 60, weight: .semibold))
                                .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.3))
                                .offset(x: 40, y: 20)
                        )
                }
            }
        }
        .frame(width: 512, height: 512)
        .clipShape(RoundedRectangle(cornerRadius: 112))
    }
}

// Text-focused design
struct AppIconTextView: View {
    var body: some View {
        ZStack {
            // Gradient background
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.7, blue: 0.95),
                    Color(red: 0.15, green: 0.4, blue: 0.85)
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            
            // Central translation icon
            VStack(spacing: 30) {
                HStack(spacing: 25) {
                    // Language flags/symbols
                    Text("文")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("A")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // App name hint
                Text("TRANSLATE")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(8)
            }
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .frame(width: 512, height: 512)
        .clipShape(RoundedRectangle(cornerRadius: 112))
    }
}