# How to Export App Icon from SwiftUI View

## Method 1: Use the HTML Generator (Easiest)
1. Open `create_icon.html` in Safari
2. Click "Download 1024x1024 (App Store)" button
3. The icon will be downloaded as a PNG file

## Method 2: Export from Xcode Preview
1. Open `AppIconView.swift` in Xcode
2. In the preview pane, click the "Export" button (share icon)
3. Choose "Export Preview"
4. Save as PNG at 1024x1024

## Method 3: Screenshot Method
1. Open `AppIconView.swift` in Xcode
2. Zoom the preview to show the icon at a good size
3. Take a screenshot (Cmd+Shift+4)
4. Select just the icon area
5. Open in Preview app and resize to 1024x1024

## Method 4: Use SwiftUI Playground
```swift
import SwiftUI
import PlaygroundSupport

// Copy your AppIconView code here
let iconView = AppIconView(size: 1024)
    .frame(width: 1024, height: 1024)

PlaygroundPage.current.setLiveView(iconView)
// Right-click the preview and save as image
```

## Adding to Xcode Project
1. Once you have the PNG file(s)
2. Open your project in Xcode
3. Go to Assets.xcassets
4. Select AppIcon
5. Drag your 1024x1024 PNG to the "1024pt App Store" slot
6. Xcode will automatically generate other sizes, or you can provide them manually