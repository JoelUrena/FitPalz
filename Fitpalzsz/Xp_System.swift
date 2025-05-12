// MARK: - FitPalz XP / Achievement System Playground
// This file contains a self‑contained model layer that:
//  • Defines immutable data models for achievements & badges
//  • Describes unlock rules using Swift protocols
//  • Evaluates unlocks against a live PlayerSnapshot
//  • Recomputes total XP + level for a user
//
//
//------------------------------------------------------------------------
import Foundation
import SwiftUI

// MARK: - Core Immutable Data Types
// Represents one long‑form accomplishment (e.g. “walk 103 435 steps”).
// Immutable so the catalogue can live safely in app bundle JSON.
struct AchievementNode : Identifiable, Hashable, Codable {
    
    let id: String  //"moonwalk-103k-steps" - stable unique key
    let name: String
    let description: String
    let baseXP: Int // XP awarded when unlocked
    let assetName: String // local image asset name
    
}

// Represents a repeatable, easier goal (think Duolingo “Close Rings”).
// Tier determines the base XP value before level multiplier.
struct BadgeNode : Identifiable, Hashable, Codable{
    
    let id: String
    let name: String
    let description: String
    let tier: Tier
    let assetName: String
    enum Tier: Int, Codable { case t1 = 15, t2 = 30, t3 = 90, t4 = 300}
}

// MARK: - Live Player Telemetry
// A snapshot of stats pulled from HealthKit / app state at evaluation time.
struct PlayerSnapshot {
    
    let totalSteps : Int
    let dailyLoginStreak : Int
    let caloriesToday : Int
    //add more
}

//Protocol every rule must satisfy
protocol UnlockRule: Sendable {
    func isSatisfied(by snapshot: PlayerSnapshot) -> Bool
}

// MARK: - Unlock Rules
// Each rule encapsulates the logic to decide if an achievement/badge
// is satisfied. Conforming types must be Sendable for concurrency safety.
// Unlock when totalSteps ≥ target
struct StepTargetRule : UnlockRule {
    let target: Int
    func isSatisfied(by s: PlayerSnapshot) -> Bool {
        s.totalSteps >= target
    }
}

// Unlock when daily login streak ≥ streak
struct LoginStreakRule : UnlockRule {
    let streak: Int
    func isSatisfied(by s: PlayerSnapshot) -> Bool {
        s.dailyLoginStreak >= streak
    }
}

// MARK: - Static Rule Registry
// Maps node IDs -> concrete UnlockRule instances.
// Lookup is O(1) and immutable at runtime.
struct UnlockRegistry {
    static let achievementRules: [String: UnlockRule] = [
        "moonwalk-103k-steps" : StepTargetRule(target: 103_435),
        "ten-day-login"       : LoginStreakRule(streak: 10),
        //ADD MORE RULES AND IDS HERE
    ] as [String: UnlockRule]  // immutable and Sendable

    static let badgeRules: [String: UnlockRule] = [
        "rings-closed-today"  : LoginStreakRule(streak: 1),
        "five-day-rings"      : LoginStreakRule(streak: 5),
        // …
    ] as [String: UnlockRule] // immutable and Sendable
}

// MARK: - JSON Loader
// Generic helper to decode bundled JSON files into strongly‑typed arrays.
extension Bundle {
    func decode<T: Decodable>(_ file: String) -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("Missing file: \(file)")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load \(file) from bundle")
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file)")
        }
        return loaded
    }
}

// MARK: - Catalogue / Evaluator
// Loads achievement + badge metadata once, then tests unlock conditions.
final class AchBadgeGallery {
    let achievements: [AchievementNode]
    let badges: [BadgeNode]

    init() {
        achievements = Bundle.main.decode("achievements.json")
        badges       = Bundle.main.decode("badges.json")
    }

    /// Returns newly-earned IDs
    func evaluateUnlocks(for snapshot: PlayerSnapshot,
                         alreadyUnlocked ids: Set<String>) -> [String] {
        // Build a combined ID list, drop already‑owned IDs, then test rules.
        let newlyUnlocked = (
            achievements.map(\.id) + badges.map(\.id)
        ).filter { id in
            guard !ids.contains(id) else { return false }
            let rule = UnlockRegistry.achievementRules[id]
                      ?? UnlockRegistry.badgeRules[id]
            return rule?.isSatisfied(by: snapshot) ?? false
        }

        return newlyUnlocked
    }
}

// MARK: - PSN‑style Level Thresholds
// Lookup table matching Sony’s pre‑2020 XP curve (Level 1–50).
struct XPTable {
    static let thresholds = [0, 200, 600, 1_200, 2_400, 4_000, 6_000, 8_000, 10_000, 12_000, 14_000, 16_000, 24_000, 32_000, 40_000,
                             48_000, 56_000, 64_000, 72_000, 80_000, 88_000, 96_000, 104_000, 112_000, 120_000, 128_000,
                             138_000, 148_000, 158_000, 168_000, 178_000, 188_000, 198_000, 208_000, 218_000, 228_000,
                             238_000, 248_000, 258_000, 268_000, 278_000, 288_000, 298_000, 308_000, 318_000, 328_000, 338_000,
                             348_000, 358_000, 368_000]
}

// Calculates badge XP after applying level‑based multiplier.
extension BadgeNode.Tier {
    func xp(atLevel level: Int) -> Int {
        // multiplier: 1 + level ⁄ 100
        Int(Double(rawValue) * (1.0 + Double(level) / 100.0))
    }
}

// MARK: - Persistence Stubs
// Minimal models required for the playground to compile.
struct UnlockRecord: Identifiable, Codable, Sendable {
    let id: String
    var date: Date

    init(id: String, date: Date = Date()) {
        self.id  = id
        self.date = date
    }
}


struct UserModel {
    var unlockIDs: Set<String> = []
    var history: [UnlockRecord] = []
    //var level: Int = 1
    var totalXP: Int = 0
}


// MARK: - XP Processor
// Orchestrates unlock evaluation and XP recomputation for a user.
final class XPSystem {
    let gallery = AchBadgeGallery()   // internal read‑only access

    func process(snapshot: PlayerSnapshot,
                 user: inout UserModel) {

        // 1. check for new unlocks
        let newIDs = gallery.evaluateUnlocks(for: snapshot,
                                             alreadyUnlocked: user.unlockIDs)

        guard !newIDs.isEmpty else { return }

        // 2. record them
        user.unlockIDs.formUnion(newIDs)
        user.history.append(contentsOf: newIDs.map { UnlockRecord(id: $0) })

        // 3. recalculate total XP once
        user.totalXP = computeXP(from: user.unlockIDs, givenXP: user.totalXP)
    }

    /*
     Computes total XP from a set of unlock IDs.

     - Parameters:
       - ids:    All unlocked achievement/badge IDs.
       - xp:     The player’s current XP total (used to derive level for badge scaling).

     - Returns:  The summed XP value.
     */
    private func computeXP(from ids: Set<String>, givenXP xp: Int) -> Int {
        let lvl = levelForXP(xp)
        return ids.reduce(0) { sum, id in
            if let ach = gallery.achievements.first(where: { $0.id == id }) {
                return sum + ach.baseXP
            } else if let badge = gallery.badges.first(where: { $0.id == id }) {
                return sum + badge.tier.xp(atLevel: lvl)
            }
            return sum
        }
    }
}


// Returns the 1-based level for a given XP total using XPTable.thresholds
func levelForXP(_ xp: Int) -> Int {
    // find the highest threshold that is ≤ xp
    return (XPTable.thresholds.lastIndex(where: { xp >= $0 }) ?? 0) + 1
}

// Returns the percent progress (0‒100) toward the next level
func percentToNextLevel(for xp: Int) -> Double {
    let lvl = levelForXP(xp)
    // if already at max table entry, you're 100 %
    guard lvl < XPTable.thresholds.count else { return 100.0 }
    let current = XPTable.thresholds[lvl - 1]
    let next    = XPTable.thresholds[lvl]
    return Double(xp - current) / Double(next - current) * 100.0
}



// Move recalcLevel into UserModel using extension
extension UserModel {
    /*
     Recomputes the user's level from their current totalXP.
     */
//    mutating func recalcLevel() {
//        level = levelForXP(totalXP)
//    }
}


struct Xp_System: View {
    // 1.  Store the model in @State so SwiftUI can refresh the UI later
    @State private var user = UserModel()
    private let xpEngine = XPSystem()

    var body: some View {
        // 2.  UI reads the model only
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Unlocked IDs: \(user.unlockIDs.sorted().joined(separator: ", "))")
            Text("Total XP    : \(user.totalXP)")
            Text("Level       : \(levelForXP(user.totalXP))")

            let pct = percentToNextLevel(for: user.totalXP)
            Text(String(format: "Progress    : %.1f %% to next level", pct))

            let achievementsEarned = user.unlockIDs.filter { id in
                xpEngine.gallery.achievements.contains(where: { $0.id == id })
            }

            let badgesEarned = user.unlockIDs.filter { id in
                xpEngine.gallery.badges.contains(where: { $0.id == id })
            }
            Text("Achievements: \(achievementsEarned.count) | Badges: \(badgesEarned.count)")
        }
        .padding()
        // 3.  Update the model once the view appears
        .onAppear {
            var tmp = user
            let snap = PlayerSnapshot(totalSteps: 105_000,
                                      dailyLoginStreak: 10,
                                      caloriesToday: 500)
            xpEngine.process(snapshot: snap, user: &tmp)
            user = tmp                       // trigger UI refresh
        }
    }
}



#Preview {

    Xp_System()

}



