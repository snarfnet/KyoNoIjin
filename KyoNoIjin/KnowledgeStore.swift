import Foundation
import SwiftUI

class KnowledgeStore: ObservableObject {
    @Published var level: Int = 1
    @Published var totalKnown: Int = 0
    @Published var totalUnknown: Int = 0
    @Published var streak: Int = 0
    @Published var showLevelUp: Bool = false

    private let defaults = UserDefaults.standard

    var totalSwiped: Int { totalKnown + totalUnknown }
    var knowledgeRate: Double {
        guard totalSwiped > 0 else { return 0 }
        return Double(totalKnown) / Double(totalSwiped)
    }

    var xpForNextLevel: Int { level * 10 }
    var currentXP: Int { totalSwiped % xpForNextLevel }
    var progress: Double { Double(currentXP) / Double(xpForNextLevel) }

    var levelTitle: String {
        switch level {
        case 1...3: return "見習い"
        case 4...6: return "物知り"
        case 7...9: return "博識"
        case 10...14: return "賢者"
        case 15...19: return "大賢者"
        default: return "全知"
        }
    }

    init() {
        load()
    }

    func recordSwipe(_ direction: SwipeDirection) {
        switch direction {
        case .right:
            totalKnown += 1
            streak += 1
        case .left:
            totalUnknown += 1
            streak = 0
        }

        let newLevel = (totalSwiped / 10) + 1
        if newLevel > level {
            level = newLevel
            showLevelUp = true
        }

        save()
    }

    private func save() {
        defaults.set(level, forKey: "kni_level")
        defaults.set(totalKnown, forKey: "kni_known")
        defaults.set(totalUnknown, forKey: "kni_unknown")
        defaults.set(streak, forKey: "kni_streak")
    }

    private func load() {
        level = max(1, defaults.integer(forKey: "kni_level"))
        totalKnown = defaults.integer(forKey: "kni_known")
        totalUnknown = defaults.integer(forKey: "kni_unknown")
        streak = defaults.integer(forKey: "kni_streak")
    }
}
