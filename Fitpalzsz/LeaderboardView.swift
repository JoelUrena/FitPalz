import SwiftUI

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Comparable {
    let id: UUID = UUID()
    let name: String
    let xp: Int
    let badges: Int
    let achievements: Int
    
    // Comparable conformance for sorting (higher XP first)
    static func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
        lhs.xp > rhs.xp   // reverse order for descending
    }
}

/// Fake data provider – replace later with Firebase fetch
final class LeaderboardStore: ObservableObject {
    @Published var top10AllTime: [LeaderboardEntry] = []
    @Published var top10Weekly: [LeaderboardEntry] = []
    
    // ───────── LeaderboardStore.init ─────────
    init() {
        // hard‑coded mock top‑10 for now
        let mockTop = (0..<10).map { i in
            LeaderboardEntry(name: "Top \(i + 1)",
                             xp: 100_000 - i * 5_000,
                             badges: 0,
                             achievements: 0)
        }
        top10AllTime = mockTop
        top10Weekly = mockTop.shuffled()
    }
    /// Converts FriendStore friends to LeaderboardEntry array
    @MainActor
    static func entries(from friendStore: FriendStore) -> [LeaderboardEntry] {
        friendStore.friends.map { f in
            LeaderboardEntry(
                name: f.contact.name,
                xp: f.user.totalXP,
                badges: f.user.unlockIDs.filter { id in
                    XPSystem().gallery.badges.contains(where: { $0.id == id })
                }.count,
                achievements: f.user.unlockIDs.filter { id in
                    XPSystem().gallery.achievements.contains(where: { $0.id == id })
                }.count
            )
        }
    }
}

// MARK: - Leaderboard Row
private struct LBRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    var body: some View {
        HStack {
            Text("#\(rank)")
                .frame(width: 40, alignment: .leading)
            VStack(alignment: .leading) {
                Text(entry.name)
                Text("B \(entry.badges) | A \(entry.achievements)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(entry.xp) XP").bold()
        }
    }
}

// MARK: - Leaderboard Screen
struct LeaderboardView: View {
    @EnvironmentObject var friendStore: FriendStore
    @StateObject private var store = LeaderboardStore()   // no parameters
    
    @State private var showWeekly = false
    
    var body: some View {
        VStack {
            Picker("Mode", selection: $showWeekly) {
                Text("Weekly").tag(true)
                Text("All‑Time").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                // Top‑10 section
                Section("Top 10") {
                    ForEach(currentTop10.indices, id: \.self) { i in
                        LBRow(rank: i + 1, entry: currentTop10[i])
                    }
                }
                
                // Your Rank
                Section("Your Rank") {
                    LBRow(rank: userRank, entry: currentUserEntry)
                        .foregroundStyle(.yellow)
                }
                
                // Your Friends
                if !currentFriends.isEmpty {
                    Section("Your Friends") {
                        ForEach(currentFriends.indices, id: \.self) { i in
                            LBRow(rank: friendRanks[i], entry: currentFriends[i])
                        }
                    }
                }
            }
        }
        .navigationTitle("Leaderboard")
    }
    
    // Helpers to pick weekly/all‑time arrays
    private var currentTop10: [LeaderboardEntry] {
        showWeekly ? store.top10Weekly : store.top10AllTime
    }
    private var currentUserEntry: LeaderboardEntry {
        let current = friendStore.currentUser
        return LeaderboardEntry(
            name: "You",
            xp: current.totalXP,
            badges: current.unlockIDs.filter { id in
                XPSystem().gallery.badges.contains(where: { $0.id == id })
            }.count,
            achievements: current.unlockIDs.filter { id in
                XPSystem().gallery.achievements.contains(where: { $0.id == id })
            }.count
        )
    }
    private var currentFriends: [LeaderboardEntry] {
        LeaderboardStore.entries(from: friendStore)
            .sorted()
            .prefix(10)
            .map { $0 }
    }
    private var userRank: Int {
        // For mock demo, assume rank is 42 / 38
        showWeekly ? 39 : 43
    }
    private var friendRanks: [Int] {
        currentFriends.enumerated().map { idx, _ in idx + 1 }
    }
}

// MARK: - Preview
#if DEBUG
struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        let friendStore = FriendStore()
        LeaderboardView()
            .environmentObject(friendStore)
            .previewDisplayName("Leaderboard")
    }
}
#endif
