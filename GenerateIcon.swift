import Cocoa

let iconsetPath = "/tmp/Leo.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try? fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true, attributes: nil)

let sizes: [(String, Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

for (name, px) in sizes {
    let s = CGFloat(px)
    let image = NSImage(size: NSSize(width: s, height: s), flipped: false) { rect in
        // White rounded-rect background
        NSColor.white.setFill()
        NSBezierPath(roundedRect: rect, xRadius: s * 0.18, yRadius: s * 0.18).fill()
        // Lion emoji
        let emoji = "🦁" as NSString
        let fontSize = s * 0.65
        let font = NSFont.systemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let emojiSize = emoji.size(withAttributes: attrs)
        let x = (s - emojiSize.width) / 2
        let y = (s - emojiSize.height) / 2
        emoji.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
        return true
    }
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }
    try? png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
}

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconsetPath, "-o", "AppIcon.icns"]
try? task.run()
task.waitUntilExit()
try? fm.removeItem(atPath: iconsetPath)
print("✅ AppIcon.icns generated")
