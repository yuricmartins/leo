import Cocoa

let week18StartStr = "2026-03-24"
let dueDateStr     = "2026-08-25"
let pregnancyDayAtWeek18Start = 119

struct BabyInfo {
    let week: Int
    let day: Int
    let daysLeft: Int
    let totalDays: Int
}

func getBabyInfo() -> BabyInfo {
    let cal = Calendar.current
    let now = Date()
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"
    fmt.timeZone = TimeZone.current
    let week18Date = fmt.date(from: week18StartStr)!
    let dueDate = fmt.date(from: dueDateStr)!
    let daysSinceWeek18 = cal.dateComponents([.day], from: cal.startOfDay(for: week18Date), to: cal.startOfDay(for: now)).day ?? 0
    let totalDays = pregnancyDayAtWeek18Start + daysSinceWeek18
    let currentWeek = (totalDays / 7) + 1
    let dayInWeek = totalDays % 7
    let daysLeft = max(0, cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: dueDate)).day ?? 0)
    return BabyInfo(week: currentWeek, day: dayInWeek, daysLeft: daysLeft, totalDays: totalDays)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateDisplay()
        setupMenu()
        scheduleNextMidnightRefresh()
    }

    func scheduleNextMidnightRefresh() {
        let cal = Calendar.current
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) else { return }
        let interval = tomorrow.timeIntervalSinceNow + 1
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.updateDisplay()
            self?.setupMenu()
            self?.scheduleNextMidnightRefresh()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func updateDisplay() {
        guard let button = statusItem.button else { return }
        let info = getBabyInfo()
        let font = NSFont.systemFont(ofSize: 13, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .baselineOffset: -0.5]
        let full = NSMutableAttributedString()
        full.append(NSAttributedString(string: "🦁", attributes: attrs))
        let spacerImage = NSImage(size: NSSize(width: 6, height: 16), flipped: false) { _ in return true }
        let spacerAttachment = NSTextAttachment()
        spacerAttachment.image = spacerImage
        spacerAttachment.bounds = CGRect(x: 0, y: 0, width: 6, height: 1)
        full.append(NSAttributedString(attachment: spacerAttachment))
        full.append(NSAttributedString(string: "Week \(info.week)", attributes: attrs))
        full.append(NSAttributedString(string: "  ", attributes: [.font: font]))
        full.append(NSAttributedString(string: "\(info.daysLeft) days left", attributes: attrs))
        button.attributedTitle = full
    }

    func setupMenu() {
        let menu = NSMenu()
        let info = getBabyInfo()
        let h = NSMenuItem(title: "🦁 Leo", action: nil, keyEquivalent: ""); h.isEnabled = false; menu.addItem(h)
        menu.addItem(NSMenuItem.separator())
        let w = NSMenuItem(title: "Week \(info.week), Day \(info.day)", action: nil, keyEquivalent: ""); w.isEnabled = false; menu.addItem(w)
        let d = NSMenuItem(title: "Pregnancy day \(info.totalDays) of ~280", action: nil, keyEquivalent: ""); d.isEnabled = false; menu.addItem(d)
        let l = NSMenuItem(title: "\(info.daysLeft) days until August 25", action: nil, keyEquivalent: ""); l.isEnabled = false; menu.addItem(l)
        menu.addItem(NSMenuItem.separator())
        let q = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"); q.target = self; menu.addItem(q)
        statusItem.menu = menu
    }

    @objc func quitApp() { NSApplication.shared.terminate(nil) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
