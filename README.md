# Native Translator iOS App

A native iOS translation app that leverages the Gemini-powered backend translation service to provide accurate, context-aware translations.

## Setup Instructions for Xcode

### Creating the Xcode Project

1. **Open Xcode** and select "Create New Project"
2. Choose **iOS** → **App**
3. Configure the project:
   - Product Name: `NativeTranslator`
   - Team: Select your team
   - Organization Identifier: Your identifier (e.g., `com.yourname`)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Use Core Data: **Unchecked**
   - Include Tests: Optional

4. **Save the project** to `/Users/guochen/code/` (it will create its own NativeTranslator folder)

### Adding the Source Files

After creating the project in Xcode:

1. **Delete the default ContentView.swift** that Xcode created
2. **Right-click on the project navigator** and select "Add Files to NativeTranslator"
3. **Navigate to** `/Users/guochen/code/NativeTranslator/NativeTranslator/`
4. **Select all the Swift files and folders**:
   - `NativeTranslatorApp.swift` (replace the existing one)
   - `ContentView.swift`
   - `Models` folder
   - `Services` folder
   - `Views` folder
5. Make sure **"Copy items if needed"** is checked
6. Click **Add**

### Configure App Transport Security

1. In Xcode, select your project in the navigator
2. Select your app target
3. Go to the **Info** tab
4. Add a new row: **App Transport Security Settings**
5. Expand it and add: **Exception Domains**
6. Add **localhost** with **NSExceptionAllowsInsecureHTTPLoads** = YES

Or add this to your Info.plist:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Running the App

1. **Start the backend service**:
   ```bash
   cd /Users/guochen/code/translation-service
   npm start
   ```
   The service should be running on port 3001

2. **Select a simulator** or connect your iOS device
3. **Click the Run button** (▶️) or press Cmd+R
4. The app should build and launch

## File Structure

```
NativeTranslator/
├── NativeTranslator/
│   ├── NativeTranslatorApp.swift    # App entry point
│   ├── ContentView.swift             # Main view
│   ├── Models/
│   │   ├── Language.swift           # Language definitions
│   │   └── TranslationModels.swift  # API models
│   ├── Services/
│   │   └── TranslationService.swift # Backend integration
│   └── Views/
│       ├── TranslationBoxView.swift   # Text input/output
│       ├── LanguageSelectorView.swift # Language picker
│       └── ContextPopupView.swift     # Context input
└── README.md
```

## Features

- Split screen layout (adapts to orientation)
- 20+ language support with auto-detect
- Context-aware translations
- Copy & paste functionality
- Real-time translation with loading indicator
- Error handling

## Troubleshooting

### If the app can't connect to the backend:
1. Verify the backend is running: `curl http://localhost:3001/api/health`
2. Check that port 3001 is correct in TranslationService.swift
3. Ensure App Transport Security exceptions are configured

### If you see build errors:
1. Make sure minimum iOS deployment target is set to iOS 16.0
2. Verify all Swift files are added to the target
3. Clean build folder: Shift+Cmd+K
4. Rebuild: Cmd+B