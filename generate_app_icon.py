#!/usr/bin/env python3
"""
App Icon Generator for Native Translator
Creates a simple, clean app icon using PIL
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size=1024):
    """Create the app icon at specified size"""
    
    # Create a new image with gradient background
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (blue theme)
    for y in range(size):
        # Gradient from light blue to darker blue
        ratio = y / size
        r = int(51 + (102 - 51) * ratio)  # 51 to 102
        g = int(153 + (204 - 153) * ratio)  # 153 to 204
        b = int(230 + (255 - 230) * ratio)  # 230 to 255
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b))
    
    # Add rounded corners
    corner_radius = int(size * 0.22)  # iOS standard corner radius
    
    # Create mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    
    # Apply rounded corners
    output = Image.new('RGB', (size, size), (255, 255, 255))
    output.paste(img, (0, 0))
    
    # Draw main translation symbol
    center_x = size // 2
    center_y = size // 2
    
    # Draw "A → 文" to represent translation
    # Left side - Roman letter
    font_size = int(size * 0.25)
    try:
        # Try to use a system font
        from PIL import ImageFont
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw white background circles for letters
    circle_radius = int(size * 0.18)
    circle_y = center_y - int(size * 0.05)
    
    # Left circle (for 'A')
    left_circle_x = center_x - int(size * 0.25)
    draw.ellipse(
        [(left_circle_x - circle_radius, circle_y - circle_radius),
         (left_circle_x + circle_radius, circle_y + circle_radius)],
        fill=(255, 255, 255),
        outline=(255, 255, 255)
    )
    
    # Right circle (for '文')
    right_circle_x = center_x + int(size * 0.25)
    draw.ellipse(
        [(right_circle_x - circle_radius, circle_y - circle_radius),
         (right_circle_x + circle_radius, circle_y + circle_radius)],
        fill=(255, 255, 255),
        outline=(255, 255, 255)
    )
    
    # Draw arrow between circles
    arrow_y = circle_y
    arrow_start_x = left_circle_x + circle_radius + int(size * 0.02)
    arrow_end_x = right_circle_x - circle_radius - int(size * 0.02)
    arrow_width = int(size * 0.015)
    
    # Arrow line
    draw.rectangle(
        [(arrow_start_x, arrow_y - arrow_width),
         (arrow_end_x, arrow_y + arrow_width)],
        fill=(255, 255, 255)
    )
    
    # Arrow head
    arrow_head_size = int(size * 0.04)
    draw.polygon(
        [(arrow_end_x, arrow_y - arrow_head_size),
         (arrow_end_x + arrow_head_size, arrow_y),
         (arrow_end_x, arrow_y + arrow_head_size)],
        fill=(255, 255, 255)
    )
    
    # Draw text on circles
    # Left text "A"
    draw.text(
        (left_circle_x, circle_y),
        "A",
        fill=(51, 153, 230),
        font=font,
        anchor="mm"
    )
    
    # Right text "文" (Chinese character)
    draw.text(
        (right_circle_x, circle_y),
        "文",
        fill=(51, 153, 230),
        font=font,
        anchor="mm"
    )
    
    # Add subtle globe icon in bottom
    globe_size = int(size * 0.12)
    globe_x = center_x
    globe_y = center_y + int(size * 0.3)
    
    draw.ellipse(
        [(globe_x - globe_size, globe_y - globe_size),
         (globe_x + globe_size, globe_y + globe_size)],
        outline=(255, 255, 255, 128),
        width=int(size * 0.008)
    )
    
    # Globe lines
    draw.arc(
        [(globe_x - globe_size, globe_y - globe_size),
         (globe_x + globe_size, globe_y + globe_size)],
        start=0, end=180,
        fill=(255, 255, 255, 100),
        width=int(size * 0.006)
    )
    
    return output

def generate_all_sizes():
    """Generate all required iOS app icon sizes"""
    
    sizes = {
        'Icon-20@2x.png': 40,
        'Icon-20@3x.png': 60,
        'Icon-29@2x.png': 58,
        'Icon-29@3x.png': 87,
        'Icon-40@2x.png': 80,
        'Icon-40@3x.png': 120,
        'Icon-60@2x.png': 120,
        'Icon-60@3x.png': 180,
        'Icon-1024.png': 1024,  # App Store
    }
    
    # Create AppIcon directory
    icon_dir = '/Users/guochen/code/NativeTranslator/AppIcon.appiconset'
    os.makedirs(icon_dir, exist_ok=True)
    
    # Generate the main icon at 1024x1024
    main_icon = create_app_icon(1024)
    
    # Save all sizes
    for filename, size in sizes.items():
        resized = main_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(icon_dir, filename))
        print(f"Generated {filename} at {size}x{size}")
    
    # Create Contents.json for Xcode
    contents_json = '''
{
  "images" : [
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
'''
    
    with open(os.path.join(icon_dir, 'Contents.json'), 'w') as f:
        f.write(contents_json.strip())
    
    print(f"\nAll icons generated in: {icon_dir}")
    print("To use in Xcode:")
    print("1. Open your project in Xcode")
    print("2. Select Assets.xcassets")
    print("3. Delete the existing AppIcon")
    print("4. Drag the AppIcon.appiconset folder into Assets.xcassets")

if __name__ == "__main__":
    try:
        generate_all_sizes()
    except ImportError:
        print("PIL/Pillow not installed. Installing...")
        import subprocess
        subprocess.check_call(["pip3", "install", "Pillow"])
        print("Pillow installed. Please run the script again.")