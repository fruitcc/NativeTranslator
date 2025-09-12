import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @AppStorage("backendURL") private var backendURL = "https://translation-service-gemini.onrender.com"
    @State private var tempURL: String = ""
    @State private var isTestingConnection = false
    @State private var testResult: TestResult?
    @State private var showTestResult = false
    
    enum TestResult {
        case success(String)
        case failure(String)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backend Configuration")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Translation Service URL")
                            .font(.headline)
                        
                        TextField("Enter backend URL", text: $tempURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onAppear {
                                tempURL = backendURL
                            }
                        
                        Text("Default: https://translation-service-gemini.onrender.com")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    
                    Button(action: testConnection) {
                        HStack {
                            if isTestingConnection {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Testing Connection...")
                            } else {
                                Image(systemName: "network")
                                Text("Test Connection")
                            }
                        }
                    }
                    .disabled(isTestingConnection || tempURL.isEmpty)
                    
                    if let result = testResult {
                        HStack {
                            switch result {
                            case .success(let message):
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.green)
                            case .failure(let message):
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Connection Status")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current URL:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(backendURL)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Make sure your backend service is running on the specified URL.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Backend API")
                        Spacer()
                        Text("Gemini Translation Service")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        tempURL = backendURL // Reset to saved value
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        backendURL = tempURL
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .disabled(tempURL.isEmpty || tempURL == backendURL)
                }
            }
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        testResult = nil
        
        // Create test request
        guard let url = URL(string: "\(tempURL)/api/health") else {
            testResult = .failure("Invalid URL format")
            isTestingConnection = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let success = json["success"] as? Bool,
                           success == true,
                           let data = json["data"] as? [String: Any],
                           let status = data["status"] as? String,
                           status == "healthy" {
                            await MainActor.run {
                                testResult = .success("Connection successful!")
                                isTestingConnection = false
                            }
                        } else {
                            await MainActor.run {
                                testResult = .failure("Invalid response from server")
                                isTestingConnection = false
                            }
                        }
                    } else {
                        await MainActor.run {
                            testResult = .failure("Server returned status: \(httpResponse.statusCode)")
                            isTestingConnection = false
                        }
                    }
                } else {
                    await MainActor.run {
                        testResult = .failure("Invalid response")
                        isTestingConnection = false
                    }
                }
            } catch {
                await MainActor.run {
                    if error.localizedDescription.contains("Could not connect") {
                        testResult = .failure("Cannot connect - is the server running?")
                    } else {
                        testResult = .failure("Connection failed: \(error.localizedDescription)")
                    }
                    isTestingConnection = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}